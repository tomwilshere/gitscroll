class Project < ActiveRecord::Base
  has_many :commits, dependent: :destroy
  has_many :commit_files, through: :commits
  has_many :file_metrics, through: :commits
  has_many :metric_stats, dependent: :destroy
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
    repo = Rugged::Repository.clone_at(self.repo_remote_url, self.repo_local_url)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE)
    walker.push(repo.head.target)
    rugged_commits = []
    walker.each do |rugged_commit|
      rugged_commits.push(rugged_commit)
    end
    self.num_commits = rugged_commits.size
  end

  # Verifies a local copy of the repo exists
  def exists
    Dir.exists? self.repo_local_url
  end

  def destroy
    FileUtils.rm_rf Dir.glob(self.repo_local_url)
    super
  end

end
