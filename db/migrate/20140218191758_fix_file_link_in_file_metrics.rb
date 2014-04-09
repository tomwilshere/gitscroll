class FixFileLinkInFileMetrics < ActiveRecord::Migration
  def change
  	rename_column :file_metrics, :file_id, :commit_file_id
  end
end
