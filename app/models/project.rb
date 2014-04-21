class Project < ActiveRecord::Base
  has_many :commits, dependent: :destroy
  has_many :commit_files, through: :commits

  def init
  	require 'securerandom'
  	
  	# make repos directory if it doesn't exist
  	Dir.mkdir("repos") if !Dir.exists?("repos")

  	directory = "repos/" + SecureRandom.uuid
  	Dir.mkdir(directory)
  	self.repo_local_url = directory
  	repo = Rugged::Repository.clone_at(self.repo_remote_url, directory)
  end
end
