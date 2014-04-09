class Project < ActiveRecord::Base
  has_many :commits, dependent: :destroy
  has_many :commit_files, through: :commits

  def init
  	require 'securerandom'
  	directory = "repos/" + SecureRandom.uuid
  	Dir.mkdir(directory)
  	self.repo_local_url = directory
  	repo = Rugged::Repository.clone_at(self.repo_remote_url, directory)
  end
end
