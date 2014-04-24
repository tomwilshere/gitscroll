class IncreaseTreeJsonTextLimit < ActiveRecord::Migration
  def change
  	change_column :commits, :tree_json, :text, :limit => 4294967295
  end
end
