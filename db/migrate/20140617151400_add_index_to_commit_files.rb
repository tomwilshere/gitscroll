class AddIndexToCommitFiles < ActiveRecord::Migration
  def change
  	add_index :commit_files, ["git_hash", "project_id"], :unique => true
  end
end
