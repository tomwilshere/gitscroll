class FixHashName < ActiveRecord::Migration
  def change
  	rename_column :commits, :hash, :git_hash
  end
end
