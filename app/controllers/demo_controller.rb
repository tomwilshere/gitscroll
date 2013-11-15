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
		@fileCommits.each_with_index do |c,i|
			puts i
			if i > 0
				puts @fileCommits[i-1]
				@diffs[i] = repo.diff(@fileCommits[i-1].id,c.id,@file).first.diff
			else
				@diffs[i] = "New file"
			end
		end

		endTime = Time.now
		if @fileCommits.size == 0
			not_found("File '" + @file + "' not in git repository.")
		end
		@elapsedTime = endTime - beginningTime
		@initialCommitHash = @fileCommits.last.id
	end
end
