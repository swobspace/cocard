class AddDeliveryToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :delivery_date, :date
    add_column :card_terminals, :supplier, :string, default: ""
    add_column :card_terminals, :firmware_version, :string, default: ""
  end
end
