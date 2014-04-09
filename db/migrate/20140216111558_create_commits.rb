class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.references :project
      t.string :hash
      t.string :message
      t.references :author
      t.timestamp :date

      t.timestamps
    end
    add_index :commits, :project_id
    add_index :commits, :hash
    add_index :commits, :author_id
  end
end
