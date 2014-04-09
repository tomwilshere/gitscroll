require "#{Rails.root}/app/helpers/projects_helper"
include ProjectsHelper
namespace :project do
  desc "TODO"
  task :update_metrics => :environment do |t, args|
  	update_metrics(Project.find(2))
  end

end
