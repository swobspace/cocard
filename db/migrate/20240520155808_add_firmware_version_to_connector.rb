class AddFirmwareVersionToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :firmware_version, :string, default: ""
  end
end
