class AddAccessibilityToNetwork < ActiveRecord::Migration[7.1]
  def change
    add_column :networks, :accessibility, :integer, default: 0
  end
end
