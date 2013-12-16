class FileController < ApplicationController

	def view
		beginningTime = Time.now
		repo = Grit::Repo.new("/Users/tw310/cpp")
		@file = params[:path]
		if params[:format]
			@file += "." + params[:format]
		end
		@fileCommits = repo.log("master", @file).reverse
		if @fileCommits.size == 0
			not_found("File '" + @file + "' not in git repository.")
		end
		@hashArray = @fileCommits.map{|c| c.id}
		@diffs = []
		@additions = []
		timelineDates = []
		@fileCommits.each_with_index do |c,i|
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

			#create Timeline date object
			date = {}
			date[:startDate] = c.date
			date[:endDate] = c.date
			date[:headline] = c.message
			date[:classname] = c.id
			timelineDates.push date

		end

		timeline = {}
		timeline[:type] = "default"
		timeline[:date] = timelineDates
		@timelineObject = {}
		@timelineObject[:timeline] = timeline

		endTime = Time.now
		@elapsedTime = endTime - beginningTime
		@initialCommitHash = @fileCommits.last.id
	end
end
