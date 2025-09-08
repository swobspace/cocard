class CreateTIClients < ActiveRecord::Migration[7.2]
  def change
    create_table :ti_clients do |t|
      t.belongs_to :connector, null: false, foreign_key: true
      t.string :name, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
