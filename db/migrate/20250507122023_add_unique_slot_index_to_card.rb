class AddUniqueSlotIndexToCard < ActiveRecord::Migration[7.2]
  def up
    remove_index :cards, :card_terminal_slot_id
    add_index :cards, :card_terminal_slot_id, unique: true
  end

  def down
    # do nothing
  end
end
