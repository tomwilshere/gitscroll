class AddDeletedFilesToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :deleted_files, :string
  end
end
