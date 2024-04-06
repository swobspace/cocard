class CreateJoinTableClientConnector < ActiveRecord::Migration[7.1]
  def change
    create_join_table :clients, :connectors do |t|
      t.index [:client_id, :connector_id], unique: true
      t.index [:connector_id, :client_id], unique: true
    end
  end
end
