class AddCommitNumberToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :commit_number, :integer
  end
end
