class AddInternalToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :card_handle, :string, default: ''
    add_column :cards, :card_type, :string, default: ''
    add_column :cards, :iccsn, :string, default: ''
    add_column :cards, :slotid, :integer, default: -1
    add_column :cards, :insert_time, :timestamp
    add_column :cards, :card_holder_name, :string, default: ''
    add_column :cards, :expiration_date, :date
    add_reference :cards, :card_terminal, null: false, foreign_key: true
  end
end
