class CreateJoinTableConnectorContext < ActiveRecord::Migration[7.1]
  def change
    create_join_table :connectors, :contexts do |t|
      t.index [:connector_id, :context_id], unique: true
      t.index [:context_id, :connector_id], unique: true
    end
  end
end
