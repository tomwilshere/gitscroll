class ChangeTypeOfDeletedFilesToText < ActiveRecord::Migration
  def change
  	change_column :commits, :deleted_files, :text
  end
end
