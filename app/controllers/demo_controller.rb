class DemoController < ApplicationController

	def index
		beginningTime = Time.now
		repo = Grit::Repo.new("/Users/tw310/cpp")
		@file = params[:path]
		if params[:format]
			@file += "." + params[:format]
		end
		@fileCommits = repo.log("master", @file).reverse
		endTime = Time.now
		if @fileCommits.size == 0
			not_found("File '" + @file + "' not in git repository.")
		end
		@elapsedTime = endTime - beginningTime
		@javascriptArrayOfHashes = @fileCommits.map{|c| c.id}
		@initialCommitHash = @fileCommits.last.id
	end
end
