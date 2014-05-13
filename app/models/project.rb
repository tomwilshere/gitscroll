class Project < ActiveRecord::Base
  has_many :commits, dependent: :destroy
  has_many :commit_files, through: :commits
  has_many :file_metrics, through: :commits
  after_initialize :generate_hash

  # Have the model assign itself a unique hash folder if
  # one is not already set.
  def generate_hash
    require 'securerandom'
    self.repo_local_url ||= "repos/#{SecureRandom.uuid}"
  end

  def init
    # Make repos directory if it doesn't exist
    Dir.mkdir("repos") if !Dir.exists?("repos")
    Dir.mkdir self.repo_local_url
    Rugged::Repository.clone_at(self.repo_remote_url, self.repo_local_url)
  end

  # Verifies a local copy of the repo exists
  def exists
    Dir.exists? self.repo_local_url
  end

end
