class CommitMetricUpdater
  @queue = :metric

  def self.perform(commit_id)
    require "#{Rails.root}/app/helpers/projects_helper"
    commit = Commit.find(commit_id)
    project = commit.project
    repo = Rugged::Repository.new(project.repo_local_url)
    rugged_commit = repo.lookup(commit.id)
    update_commit_metrics(repo, rugged_commit)
  end
end
