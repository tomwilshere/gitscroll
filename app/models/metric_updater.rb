class MetricUpdater
  @queue = :metric

  def self.perform(project_id)
    require "#{Rails.root}/app/helpers/projects_helper"
    project = Project.find(project_id)
    ProjectsHelper.update_metrics(project)
  end
end
