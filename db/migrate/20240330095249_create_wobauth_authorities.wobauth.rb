# This migration comes from wobauth (originally 20140504143328)
class CreateWobauthAuthorities < ActiveRecord::Migration[5.1]
  def change
    create_table :wobauth_authorities do |t|
      t.references :authorizable, index: true
      t.string :authorizable_type
      t.references :role, index: true
      t.references :authorized_for, index: true
      t.string :authorized_for_type
      t.date :valid_from
      t.date :valid_until

      t.timestamps
    end
  end
end
