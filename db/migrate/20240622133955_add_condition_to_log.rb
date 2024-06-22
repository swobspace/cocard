class AddConditionToLog < ActiveRecord::Migration[7.1]
  def change
    add_column :logs, :is_valid, :boolean, default: false
    add_index :logs, :is_valid
    add_column :logs, :condition, :integer, default: -1
  end
end
