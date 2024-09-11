class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.belongs_to :notable, polymorphic: true, null: false
      t.belongs_to :user, null: false, foreign_key: { to_table: 'wobauth_users' }
      t.date :valid_until
      t.integer :type, default: 0

      t.timestamps
    end
  end
end
