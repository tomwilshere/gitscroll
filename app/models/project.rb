class Project < ActiveRecord::Base
  attr_accessible :name, :repo_local_url, :repo_remote_url
end
