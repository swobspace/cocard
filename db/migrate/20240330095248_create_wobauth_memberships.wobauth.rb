# This migration comes from wobauth (originally 20140504124045)
class CreateWobauthMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :wobauth_memberships do |t|
      t.references :user, index: true
      t.references :group, index: true
      t.boolean :auto, default: false

      t.timestamps
    end
  end
end
