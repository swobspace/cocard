class CreateNetworks < ActiveRecord::Migration[7.1]
  def change
    create_table :networks do |t|
      t.cidr :netzwerk
      t.belongs_to :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
