class AddReadonlyToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :sds_xml, :text
    add_column :connectors, :sds_updated_at, :string
    add_column :connectors, :properties, :jsonb
    add_column :connectors, :last_check, :timestamp
    add_column :connectors, :last_check_ok, :timestamp
    add_column :connectors, :condition, :integer, default: 0
    add_index :connectors, :condition
  end
end
