class AddCurrentIpToCardTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :current_ip, :inet
  end
end
