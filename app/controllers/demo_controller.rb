class DemoController < ApplicationController

	def index
		beginningTime = Time.now
		repo = Grit::Repo.new("/Users/tw310/cpp")
		@file = "Gemfile"
		@fileCommits = repo.log("master", @file).reverse
		endTime = Time.now
		@elapsedTime = endTime - beginningTime
		@javascriptArrayOfHashes = @fileCommits.map{|c| c.id}
		@initialCommitHash = @fileCommits.last.id
	end
end
