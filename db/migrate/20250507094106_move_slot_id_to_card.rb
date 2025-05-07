class MoveSlotIdToCard < ActiveRecord::Migration[7.2]
  def up
    add_reference :cards, :card_terminal_slot, null: true, index: true
    Card.reset_column_information

    execute <<-SQL
      UPDATE "cards" AS card
      SET 
        card_terminal_slot_id = slot.id
      FROM card_terminal_slots AS slot
      WHERE card.id = slot.card_id
    SQL

    remove_reference :card_terminal_slots, :card, index: true
  end


  def down
    add_reference :card_terminal_slots, :card, null: true, index: true
    CardTerminalSlot.reset_column_information

    execute <<-SQL
      UPDATE "card_terminal_slots" AS slot
      SET 
        card_id = card.id
      FROM cards AS card
      WHERE card.card_terminal_slot_id = slot.id
    SQL

    remove_reference :cards, :card_terminal_slot, index: true
  end
    
end
