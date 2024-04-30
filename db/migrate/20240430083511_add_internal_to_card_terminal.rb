class AddInternalToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :properties, :jsonb
    add_column :card_terminals, :name, :string, default: ""
    add_column :card_terminals, :ct_id, :string, default: ""
    add_column :card_terminals, :mac, :macaddr
    add_column :card_terminals, :ip, :inet
    add_column :card_terminals, :connected, :boolean, default: false
    add_column :card_terminals, :condition, :integer, default: -1
    add_reference :card_terminals, :connector, null: false, foreign_key: true

    add_index :card_terminals, :mac, unique: true
  end
end
