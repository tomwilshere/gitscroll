module ProjectsHelper

	require "#{Rails.root}/app/helpers/metrics_helper"
	include MetricsHelper

	@@visited_blobs = Hash.new

	def self.get_visited_blobs
		@@visited_blobs
	end

	def self.set_visited_blobs(vb)
		@@visited_blobs = vb
	end

	def generate_parent_path(path)
		parent_path = @path.split("/")
      	parent_path.pop
      	return parent_path.join("/")
	end

    def update_metrics(project)
    	repo = Rugged::Repository.new(project.repo_local_url)
    	walker = Rugged::Walker.new(repo)
    	walker.push(repo.head.target)
    	count = 1
    	walker.each do |rugged_commit| 
    		commit = Commit.find_or_create_by_git_hash(rugged_commit.oid)
    		commit.project = project
    		commit.git_hash = rugged_commit.oid
    		commit.message = rugged_commit.message
    		commit.author = Author.find_or_create_by_name_and_email(
    			rugged_commit.author[:name], 
    			rugged_commit.author[:email])
    		commit.date = rugged_commit.author[:time]
    		commit.save
    		update_commit_metrics(repo, rugged_commit)
    		puts count
    		count = count + 1
    		puts ProjectsHelper.get_visited_blobs.size
    	end
    end

    def update_commit_metrics(repo, commit)
    	update_commit_tree(repo, commit, repo.lookup(commit.tree.oid), "")
    end

    def update_commit_tree(repo, commit, tree, path)
    	tree.each_tree do |subtree|
    		update_commit_tree(repo, commit, repo.lookup(subtree[:oid]), path + subtree[:name] + "/" )
    	end
    	tree.each_blob do |blob|
    		update_commit_file(repo, commit, blob, path)
    	end
    end

    def update_commit_file(repo, commit, blob, path)
    	blob_object = repo.lookup(blob[:oid])
		if !blob_object.binary? && !ProjectsHelper.get_visited_blobs[blob[:oid]]
			ProjectsHelper.get_visited_blobs[blob[:oid]] = true
	    	commitFile = CommitFile.find_or_create_by_git_hash(blob[:oid])
	    	commitFile.commit_id = commit.oid
	    	commitFile.path = path  + blob[:name]
	    	commitFile.save
	    	generate_file_metrics(commitFile, blob_object.content)
		end
    end

    def generate_file_metrics(commitFile, fileContents)
    	commitFile.file_metrics.destroy_all
    	all_metrics = generate_metrics(fileContents, commitFile.path.split("/").last)
    	all_metrics.each do |metric_name, score|
    		if score != nil
	    		metric = Metric.find_by_name(metric_name.to_s)
	    		file_metric_info = {:commit_file => commitFile,
	    							:score => score,
	    							:metric_id => metric.id}

	    		FileMetric.create(file_metric_info)
	    	end
    	end
    end

    def makeD3Network(tree, currentPath)
        dataset = Hash.new
        dataset[:nodes] = []
        dataset[:edges] = []
        dataset[:nodes].push(Hash[:id => tree.oid, :name => currentPath, :size => 6])
        tree.walk(:postorder) do |root, entry|
            dataset[:nodes].push(Hash[:id => entry[:oid], :name => entry[:name], :size => (entry[:type] == :blob)? 4:6])
            if root == ""
                dataset[:edges].push(Hash[:source => tree.oid, :target => entry[:oid]])
            else
                dataset[:edges].push(Hash[:source => tree.path(root[0..-2])[:oid], :target => entry[:oid]])
            end
        end
        return dataset
    end

end
