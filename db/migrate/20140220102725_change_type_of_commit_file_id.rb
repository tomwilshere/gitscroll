class ChangeTypeOfCommitFileId < ActiveRecord::Migration
  def change
  	change_column :file_metrics, :commit_file_id, :string
  end
end
