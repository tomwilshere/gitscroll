class Commit < ActiveRecord::Base
  self.primary_key = :git_hash
  belongs_to :project
  belongs_to :author
  has_many :commit_files, dependent: :destroy
  has_many :file_metrics, through: :commit_files
end
