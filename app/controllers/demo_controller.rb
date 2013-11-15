class DemoController < ApplicationController

	def index
		beginningTime = Time.now
		repo = Grit::Repo.new("/Users/tw310/cpp")
		@file = params[:path]
		if params[:format]
			@file += "." + params[:format]
		end
		@fileCommits = repo.log("master", @file).reverse
		@hashArray = @fileCommits.map{|c| c.id}
		@diffs = []
		@additions = []
		@fileCommits.each_with_index do |c,i|
			puts i
			if i > 0
				diff = repo.diff(@fileCommits[i-1].id,c.id,@file).first.diff
				@diffs[i] = diff
				@additions[i] = []

				#Extract the line number and change info from each hunk
				hunkStats = diff.split("\n").map{|l| l.match(/@@.*?,(\d+) \+(\d+),(\d+) @@/)}.reject(&:blank?)

				#for each hunk, extract the location and length of change
				hunkStats.each do |ds|
					addition = {}
					addition[:location] = ds[2].to_i + 3
					addition[:length] = ds[3].to_i - ds[1].to_i
					@additions[i].push(addition)
				end
			end
		end

		endTime = Time.now
		if @fileCommits.size == 0
			not_found("File '" + @file + "' not in git repository.")
		end
		@elapsedTime = endTime - beginningTime
		@initialCommitHash = @fileCommits.first.id
	end
end
