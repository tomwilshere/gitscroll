class Project < ActiveRecord::Base
  attr_accessible :name, :repo_local_url, :repo_remote_url

  def init
  	require 'securerandom'
  	directory = "repos/" + SecureRandom.uuid
  	Dir.mkdir(directory)
  	self.repo_local_url = directory
  	repo = Rugged::Repository.clone_at(self.repo_remote_url, directory)
  end
end
