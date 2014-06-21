module ProjectsHelper
  require "#{Rails.root}/app/helpers/metrics_helper"
  include MetricsHelper

  @visited_blobs = {}

  def generate_parent_path(path)
    parent_path = path.split('/')
    parent_path.pop
    parent_path.join('/')
  end

  @previous_files = []
  @current_files = []

  def self.update_metrics(project)
    repo = Rugged::Repository.new(project.repo_local_url)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE)
    walker.push(repo.head.target)
    count = 0
    rugged_commits = []
    walker.each do |rugged_commit|
      rugged_commits.push(rugged_commit)
    end
    rugged_commits = rugged_commits.reverse
    rugged_commits.each do |rugged_commit|
      commit = Commit.new
      commit.git_hash = rugged_commit.oid
      commit.project = project
      commit.git_hash = rugged_commit.oid
      commit.message = rugged_commit.message
      name =  rugged_commit.author[:name]
        .encode('UTF-8', 'binary', invalid: :replace,
                                   undef: :replace,
                                   replace: '')
      email = rugged_commit.author[:email]
        .encode('UTF-8', 'binary', invalid: :replace,
                                   undef: :replace,
                                   replace: '')
      commit.author = Author.find_or_create_by_name_and_email(name, email)
      commit.date = rugged_commit.author[:time]
      commit.commit_number = count
      commit.save
      # Resque.enqueue(CommitMetricUpdater, commit.id)
      update_commit_metrics(repo, rugged_commit, commit)
      commit.deleted_files = (@previous_files - @current_files).join ','
      @previous_files = @current_files
      @current_files = []
      commit.save
      puts count
      count += 1
      puts @visited_blobs.size
    end

    store_min_and_max_metrics(project)
    project.calculate_files_to_fix
  end

  def update_commit_metrics(repo, rugged_commit, commit)
    update_commit_tree(repo,
                       rugged_commit,
                       commit,
                       repo.lookup(rugged_commit.tree.oid),
                       '')
  end

  def update_commit_tree(repo, rugged_commit, commit, tree, path)
    tree.each_tree do |subtree|
      update_commit_tree(repo,
                         rugged_commit,
                         commit,
                         repo.lookup(subtree[:oid]),
                         path + subtree[:name] + '/')
    end
    tree.each_blob do |blob|
      update_commit_file(repo, rugged_commit, commit, blob, path)
    end
  end

  def self.update_commit_file(repo, rugged_commit, commit, blob, path)
    blob_object = repo.lookup(blob[:oid])
    unless blob_object.binary?
      @current_files.push(path + blob[:name])
      unless @visited_blobs[blob[:oid]]
        @visited_blobs[blob[:oid]] = true
        commit_file = CommitFile.new
        commit_file.git_hash = blob[:oid]
        commit_file.commit_id = rugged_commit.oid
        commit_file.path = path  + blob[:name]
        commit_file.project_id = commit.project_id
        commit_file.save
        generate_file_metrics(commit_file, blob_object.content)
      end
    end
  end

  def generate_file_metrics(commitFile, contents)
    all_metrics = generate_metrics(contents, commitFile.path.split('/').last)
    all_metrics.each do |metric_name, score|
      if score
        metric = Metric.find_by_name(metric_name.to_s)
        file_metric_info = { commit_file: commitFile, score: score,
                             metric_id: metric.id,
                             project_id: commitFile.project_id }
        FileMetric.create(file_metric_info)
      end
    end
  end

  def store_min_and_max_metrics(project)
    project.metric_stats.destroy_all
    file_metrics = project.file_metrics.group_by { |fm| fm.metric_id }
    Metric.all.each do |metric|
      metrics = file_metrics[metric.id]
      if metrics
        min = metrics.map { |fm| fm.score }.min
        max = metrics.map { |fm| fm.score }.max
      end
      MetricStats.create(project: project, metric: metric, min: min, max: max)
    end
  end

  def make_d3_network(commit, tree, currentPath, commitNumber)
    commit_files = commit.project.commit_files
    commit_file_ids = Hash[*commit_files.map { |cf| [cf.id, cf] }.flatten]
    file_metrics = commit.project.file_metrics
      .group_by { |fm| fm.commit_file_id }
    dataset = {}
    dataset[:hash] = commit[:git_hash]
    dataset[:date] = commit[:date]
    dataset[:message] = commit[:message]
    dataset[:author] = commit.author
    dataset[:commit_number] = commitNumber
    nodes = []
    dataset[:edges] = []
    nodes.push(Hash[id: tree.oid, name: currentPath, path: '', size: 12])
    tree.walk(:postorder) do |root, entry|
      parent_oid = (root == '') ? tree.oid : tree.path(root[0..-2])[:oid]
      node_size = (entry[:type] == :blob) ? 4 : 6
      metrics = Hash.new
      path = ''
      if commit_file_ids.include?(entry[:oid])
        cf = commit_file_ids[entry[:oid]]
        path = cf.path
        if file_metrics[cf.id]
          file_metrics[cf.id].each do |metric|
            metrics[metric.metric_id] = metric.score
          end
        end
      end
      id = entry[:oid]
      nodes.push(Hash[id: id,
                      name: entry[:name],
                      path: path,
                      size: node_size,
                      metrics: metrics])
      dataset[:edges].push(Hash[source: parent_oid, target: id])
    end
    dataset[:nodes] = nodes.sort_by { |e| e[:path] }
    dataset
  end
end
