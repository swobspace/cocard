class AddDeletedAtToConnector < ActiveRecord::Migration[7.2]
  def change
    add_column :connectors, :deleted_at, :timestamp
  end
end
