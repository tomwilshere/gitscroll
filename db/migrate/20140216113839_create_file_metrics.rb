class CreateFileMetrics < ActiveRecord::Migration
  def change
    create_table :file_metrics do |t|
      t.references :file
      t.references :metric
      t.float :score

      t.timestamps
    end
    add_index :file_metrics, :file_id
    add_index :file_metrics, :metric_id
  end
end
