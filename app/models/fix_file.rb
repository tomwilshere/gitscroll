class FixFile < ActiveRecord::Base
  belongs_to :project
  belongs_to :commit
  belongs_to :commit_file
  validates :commit_file_id, uniqueness: { scope: :project_id }
end
