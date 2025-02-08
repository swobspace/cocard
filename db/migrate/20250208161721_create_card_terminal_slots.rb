class CreateCardTerminalSlots < ActiveRecord::Migration[7.2]
  def change
    create_table :card_terminal_slots do |t|
      t.belongs_to :card_terminal, null: false, foreign_key: true
      t.belongs_to :card, null: true, index: {unique: true}, foreign_key: true
      t.integer :slot, default: -1

      t.timestamps
      t.index [:card_terminal_id, :slot], unique: true
    end
  end
end
