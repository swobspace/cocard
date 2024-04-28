class ChangeConnectorSDSUpdatedAt < ActiveRecord::Migration[7.1]
  def change
    remove_column :connectors, :sds_updated_at, type: :string
    add_column :connectors, :sds_updated_at, :timestamp
  end
end
