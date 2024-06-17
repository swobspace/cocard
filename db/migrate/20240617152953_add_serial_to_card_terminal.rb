class AddSerialToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :serial, :string, default: ''
    add_column :card_terminals, :id_product, :string, default: ''
  end
end
