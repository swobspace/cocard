class CreateOids < ActiveRecord::Migration[8.1]
  def change
    create_table :oids do |t|
      t.string :oid, null: false
      t.string :name, default: ""
      t.string :reference, default: ""

      t.timestamps
    end
    add_index :oids, :oid, unique: true
  end
end
