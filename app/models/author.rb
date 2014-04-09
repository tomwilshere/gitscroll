class Author < ActiveRecord::Base
  attr_accessible :email, :name
  has_many :commits
end
