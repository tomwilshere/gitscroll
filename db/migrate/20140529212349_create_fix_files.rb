class CreateFixFiles < ActiveRecord::Migration
  def change
    create_table :fix_files do |t|
      t.references :project, index: true
      t.string :commit_id
      t.string :commit_file_id
      t.string :path

      t.timestamps
    end
  end
end
