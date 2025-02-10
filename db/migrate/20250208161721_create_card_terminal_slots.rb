class CreateCardTerminalSlots < ActiveRecord::Migration[7.2]
  def change
    create_table :card_terminal_slots do |t|
      t.belongs_to :card_terminal, null: false, foreign_key: true
      t.belongs_to :card, null: true, index: {unique: true}, foreign_key: false
      t.integer :slotid, default: -1

      t.timestamps
      t.index [:card_terminal_id, :slotid], unique: true
    end
  end
end
