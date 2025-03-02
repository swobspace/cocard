class AddRebootedAtToCardTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :rebooted_at, :timestamp
  end
end
