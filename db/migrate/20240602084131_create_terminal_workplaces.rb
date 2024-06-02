class CreateTerminalWorkplaces < ActiveRecord::Migration[7.1]
  def change
    create_table :terminal_workplaces do |t|
      t.belongs_to :card_terminal, null: false, foreign_key: true
      t.belongs_to :workplace, null: false, foreign_key: true
      t.string :mandant, default: ""
      t.string :client_system, default: ""

      t.timestamps

      t.index [:card_terminal_id, :mandant,
               :client_system, :workplace_id], unique: true
      t.index [:workplace_id, :card_terminal_id]
      t.index [:card_terminal_id, :workplace_id]
    end
    add_index :terminal_workplaces, :mandant
    add_index :terminal_workplaces, :client_system
  end
end
