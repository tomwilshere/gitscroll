class AddTreeJsonToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :tree_json, :text
  end
end
