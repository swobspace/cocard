class AddOperationalToOperationalState < ActiveRecord::Migration[7.1]
  def change
    add_column :operational_states, :operational, :boolean, default: false
    add_index :operational_states, :operational
  end
end
