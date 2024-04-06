class CreateJoinTableConnectorLocation < ActiveRecord::Migration[7.1]
  def change
    create_join_table :connectors, :locations do |t|
      t.index [:connector_id, :location_id], unique: true
      t.index [:location_id, :connector_id], unique: true
    end
  end
end
