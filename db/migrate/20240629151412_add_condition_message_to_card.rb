class AddConditionMessageToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :condition_message, :string, default: '-'
  end
end
