class CreateTaggings < ActiveRecord::Migration[7.2]
  def change
    create_table :taggings do |t|
      t.belongs_to :taggable, polymorphic: true, null: false
      t.belongs_to :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
