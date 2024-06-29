class AddConditionMessageToCardTerminal < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :condition_message, :string, default: '-'
  end
end
