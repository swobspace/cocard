class AddIdentificationToCardTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :admin_pin, :string
    add_column :card_terminals, :identification, :string, default: ""
  end
end
