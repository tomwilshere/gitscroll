class RemoveTreeJsonFromCommits < ActiveRecord::Migration
  def change
    remove_column :commits, :tree_json, :string
  end
end
