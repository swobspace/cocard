class ChangeTIClientConnectorIndexToUnique < ActiveRecord::Migration[7.2]
  def up
    remove_index :ti_clients, :connector_id
    add_index :ti_clients, :connector_id, unique: true
  end

  def down
    # do nothing
  end
end
