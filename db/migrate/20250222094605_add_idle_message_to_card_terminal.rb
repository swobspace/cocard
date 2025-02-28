class AddIdleMessageToCardTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :idle_message, :string, default: ''
  end
end
