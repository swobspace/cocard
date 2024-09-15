class AddPinModeToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :pin_mode, :integer, default: 0
  end
end
