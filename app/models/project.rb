class Project < ActiveRecord::Base
  has_many :commits, dependent: :destroy
  has_many :commit_files
  has_many :file_metrics
  has_many :metric_stats, dependent: :destroy
  has_many :authors, through: :commits
  has_many :false_positives, dependent: :destroy
  has_many :fix_files
  after_initialize :generate_hash

  # Have the model assign itself a unique hash folder if
  # one is not already set.
  def generate_hash
    require 'securerandom'
    self.repo_local_url ||= "repos/#{SecureRandom.uuid}"
  end

  def init
    # Make repos directory if it doesn't exist
    Dir.mkdir("repos") if !Dir.exists?("repos")
    Dir.mkdir self.repo_local_url
    repo = Rugged::Repository.clone_at(self.repo_remote_url, self.repo_local_url)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE)
    walker.push(repo.head.target)
    rugged_commits = []
    walker.each do |rugged_commit|
      rugged_commits.push(rugged_commit)
    end
    self.num_commits = rugged_commits.size
  end

  # Verifies a local copy of the repo exists
  def exists
    Dir.exists? self.repo_local_url
  end

  def destroy
    FileUtils.rm_rf Dir.glob(self.repo_local_url)
    super
  end

  def calculateFilesToFix
    res = Hash.new
    fileHash = Hash.new(0)
    commit_files = self.commit_files
    commit_files_by_path = commit_files.group_by{|cf| cf.path}.values
    Metric.all.each do |metric|
      res[metric.id] = commit_files_by_path
        .map{|cfs| {commit_file: cfs.last.id, score: cfs.last.file_metrics.where(:metric_id => metric.id)[0]? cfs.last.file_metrics.where(:metric_id => metric.id)[0].score : -1}}
        .group_by{|cf| cf[:score]}.to_a
        .sort_by{|cf| cf[0]}.reverse
      res[metric.id].each_with_index do |files, index|
        files[1].each do |file|
          fileHash[file[:commit_file]] = fileHash[file[:commit_file]] + index
        end
      end
    end

    fileHash.to_a.map{|f| {project_id: self.id, commit_id: commit_files.find(f[0]).commit_id, commit_file_id: f[0], path: commit_files.find(f[0]).path, score: f[1]}}
        .each{|f| FixFile.create(f)}
    # fileHash.to_a.
    #     sort_by{|f| f[1]}
    #     .map{|f| {project_id: self.id, commit_id: self.commit_files.find(f[0]).commit_id, commit_file_id: f[0], path: self.commit_files.find(f[0]).path}}
    #     .each{|f| FixFile.create(f)}
  end

end
