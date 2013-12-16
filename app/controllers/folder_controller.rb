class FolderController < ApplicationController

	def browse
		repo = Grit::Repo.new("/Users/tw310/cpp")
		startTime = Time.now
		@commits = repo.log("master").reverse.take(10)
		@trees = @commits.map{|c| treePrint(c.tree)}
		endTime = Time.now
		@time = endTime - startTime
		@hashArray = @commits.map{|c| c.id}
	end

	def treePrint(tree)
		output = "<ul>"
		tree.trees.each do |t|
			output += "<li class=""folder"">" + t.name
			if t.trees
				output += treePrint(t)
			end
			output += "</li>"
		end
		tree.blobs.each do |b|
			output += "<li class=""file"">" + b.name + "</li>"
		end
		return output + "</ul>"
	end
	helper_method :treePrint
end
