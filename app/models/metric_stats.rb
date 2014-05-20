class MetricStats < ActiveRecord::Base
  belongs_to :project
  belongs_to :metric
  validates :metric_id, uniqueness: {scope: :project_id}
end
