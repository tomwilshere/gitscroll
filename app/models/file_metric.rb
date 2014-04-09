class FileMetric < ActiveRecord::Base
  belongs_to :commit_file
  belongs_to :metric
end
