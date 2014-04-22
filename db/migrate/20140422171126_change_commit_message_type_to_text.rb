class ChangeCommitMessageTypeToText < ActiveRecord::Migration
  def change
  	change_column :commits, :message, :text, :limit => nil
  end
end
