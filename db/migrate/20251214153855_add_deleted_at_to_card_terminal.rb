class AddDeletedAtToCardTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :deleted_at, :timestamp
  end
end
