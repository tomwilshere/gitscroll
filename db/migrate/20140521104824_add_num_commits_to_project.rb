class AddNumCommitsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :num_commits, :integer
  end
end
