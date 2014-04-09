class FileMetric < ActiveRecord::Base
  belongs_to :commit_file
  belongs_to :metric
  attr_accessible :score, :commit_file, :metric, :metric_id, :commit_file_id
end
