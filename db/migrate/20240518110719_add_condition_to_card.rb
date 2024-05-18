class AddConditionToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :condition, :integer, default: -1
    add_index :cards, :condition
    add_column :cards, :pin_status, :string, default: ""
    add_index :cards, :pin_status

    # add missing indext to card_terminal#condition
    add_index :card_terminals, :condition
  end
end
