class AddProjectIdToFileMetrics < ActiveRecord::Migration
  def change
    add_reference :file_metrics, :project, index: true
  end
end
