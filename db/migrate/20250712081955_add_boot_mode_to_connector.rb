class AddBootModeToConnector < ActiveRecord::Migration[7.2]
  def change
    add_column :connectors, :boot_mode, :integer, default: 0
    add_index :connectors, :boot_mode
  end
end
