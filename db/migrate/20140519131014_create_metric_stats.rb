class CreateMetricStats < ActiveRecord::Migration
  def change
    create_table :metric_stats do |t|
      t.references :project, index: true
      t.references :metric, index: true
      t.float :min
      t.float :max

      t.timestamps
    end
  end
end
