class CreateCommitFiles < ActiveRecord::Migration
  def change
    create_table :commit_files do |t|
      t.string :commit_id
      t.string :hash
      t.string :path
      t.text :contents

      t.timestamps
    end
    add_index :commit_files, :commit_id
    add_index :commit_files, :hash
  end
end
