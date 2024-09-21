class AddAcknowledgeIdToOthers < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :acknowledge_id, :bigint
    add_column :cards, :acknowledge_id, :bigint
    add_column :card_terminals, :acknowledge_id, :bigint
  end
end
