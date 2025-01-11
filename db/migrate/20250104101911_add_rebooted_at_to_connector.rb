class AddRebootedAtToConnector < ActiveRecord::Migration[7.2]
  def change
    add_column :connectors, :rebooted_at, :timestamp
  end
end
