class CommitFile < ActiveRecord::Base
  self.primary_key = :git_hash
  belongs_to :commit
  has_many :file_metrics, dependent: :destroy
end
