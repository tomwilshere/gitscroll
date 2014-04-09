class CommitFile < ActiveRecord::Base
  self.primary_key = :git_hash
  belongs_to :commit
  has_many :file_metrics, dependent: :destroy
  attr_accessible :contents, :git_hash, :path, :commit, :commit_id
end
