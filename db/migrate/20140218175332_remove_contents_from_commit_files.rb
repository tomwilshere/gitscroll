class RemoveContentsFromCommitFiles < ActiveRecord::Migration
  def up
    remove_column :commit_files, :contents
  end

  def down
    add_column :commit_files, :contents, :text
  end
end
