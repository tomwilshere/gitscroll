class FalsePositive < ActiveRecord::Base
  belongs_to :project
  self.inheritance_column = nil
end
