class FixHashNameForCommitFile < ActiveRecord::Migration
  def change
  	rename_column :commit_files, :hash, :git_hash
  end
end
