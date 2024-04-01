class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :lid, null: false
      t.string :description, default: ""

      t.timestamps
    end
  end
end
