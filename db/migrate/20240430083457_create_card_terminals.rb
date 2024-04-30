class CreateCardTerminals < ActiveRecord::Migration[7.1]
  def change
    create_table :card_terminals do |t|
      t.string :displayname, default: ""
      t.belongs_to :location, null: true, foreign_key: true

      t.timestamps
    end
  end
end
