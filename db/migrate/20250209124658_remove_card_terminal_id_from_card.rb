class RemoveCardTerminalIdFromCard < ActiveRecord::Migration[7.2]
  def change
    remove_reference :cards, :card_terminal, null: true, foreign_key: false
    remove_column :cards, :slotid, :integer, default: -1

    remove_reference :cards, :old_context, null: true, foreign_key: false
    remove_column :cards, :old_pin_status, :string, default: ""
  end
end
