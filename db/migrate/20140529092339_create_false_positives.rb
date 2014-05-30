class CreateFalsePositives < ActiveRecord::Migration
  def change
    create_table :false_positives do |t|
      t.string :path
      t.references :project, index: true
      t.text :comment
      t.string :type

      t.timestamps
    end
  end
end
