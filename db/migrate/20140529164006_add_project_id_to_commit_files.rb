class AddProjectIdToCommitFiles < ActiveRecord::Migration
  def change
    add_reference :commit_files, :project, index: true
  end
end
