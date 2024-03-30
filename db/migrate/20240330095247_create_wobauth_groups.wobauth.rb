# This migration comes from wobauth (originally 20140501150743)
class CreateWobauthGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :wobauth_groups do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
