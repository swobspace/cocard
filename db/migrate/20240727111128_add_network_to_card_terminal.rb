class AddNetworkToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_reference :card_terminals, :network, null: true, foreign_key: false
  end
end
