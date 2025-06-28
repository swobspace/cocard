class AddObjectSystemVersionToCard < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :object_system_version, :string, default: ''
    add_index :cards, :object_system_version
  end
end
