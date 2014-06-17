class AddIndexToCommit < ActiveRecord::Migration
  def change
  	add_index :commits, ["git_hash", "project_id"], :unique => true
  end
end
