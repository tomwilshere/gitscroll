class AddExtensionListToMetric < ActiveRecord::Migration
  def change
    add_column :metrics, :extension_list, :string
  end
end
