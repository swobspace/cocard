class AddMoreLocInfoToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :room, :string, default: ""
    add_column :card_terminals, :contact, :string, default: ""
    add_column :card_terminals, :plugged_in, :string, default: ""
  end
end
