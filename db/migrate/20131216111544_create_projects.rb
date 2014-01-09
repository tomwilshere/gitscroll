class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :repo_remote_url
      t.string :repo_local_url

      t.timestamps
    end
  end
end
