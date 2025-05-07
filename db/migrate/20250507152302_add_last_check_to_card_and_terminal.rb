class AddLastCheckToCardAndTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :last_check, :timestamp
    add_column :cards, :last_check, :timestamp
    add_column :cards, :last_ok, :timestamp
  end
end
