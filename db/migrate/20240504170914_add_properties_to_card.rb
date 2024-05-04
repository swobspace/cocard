class AddPropertiesToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :properties, :jsonb
  end
end
