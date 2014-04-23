#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

namespace :db do

  desc "Init any database repos that are not present"
  task init_repos: :environment do
    for p in Project.all.select { |p| !p.exists }
      puts "Init'ing project '#{p.repo_remote_url}'"
      p.init && p.save
      puts "Done!"
    end
  end

  desc "Cleans all repo data"
  task clean_repos: :environment do
    puts "Cleaning current repos..."
    FileUtils.rm_rf Dir.glob("repos/*")
  end

end

Gitscroll::Application.load_tasks
