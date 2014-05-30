class AddScoreToFixFiles < ActiveRecord::Migration
  def change
    add_column :fix_files, :score, :float
  end
end
