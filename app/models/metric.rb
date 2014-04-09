class Metric < ActiveRecord::Base
  has_many :file_metrics
  attr_accessible :name, :extension_list
end
