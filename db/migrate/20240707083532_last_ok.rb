class LastOk < ActiveRecord::Migration[7.1]
  def change
    add_column :card_terminals, :last_ok, :timestamp
    rename_column :connectors, :last_check_ok, :last_ok
  end
end
