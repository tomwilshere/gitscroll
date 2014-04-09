class Author < ActiveRecord::Base
  has_many :commits
end
