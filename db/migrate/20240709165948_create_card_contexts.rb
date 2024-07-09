class CreateCardContexts < ActiveRecord::Migration[7.1]
  def change
    create_table :card_contexts do |t|
      t.belongs_to :card, null: false, foreign_key: true
      t.belongs_to :context, null: false, foreign_key: true
      t.integer :position, default: 0
      t.string :pin_status, default: ""
      t.integer :left_tries

      t.timestamps

      t.index [:card_id, :context_id], unique: true
      t.index [:context_id, :card_id], unique: true
    end
    add_index :card_contexts, :position
    add_index :card_contexts, :pin_status
  end
end
