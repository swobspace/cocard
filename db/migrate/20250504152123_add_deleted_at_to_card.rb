class AddDeletedAtToCard < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :deleted_at, :timestamp
  end
end
