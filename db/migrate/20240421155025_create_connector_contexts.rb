class CreateConnectorContexts < ActiveRecord::Migration[7.1]
  def change
    create_table :connector_contexts do |t|
      t.belongs_to :connector, null: false, foreign_key: true
      t.belongs_to :context, null: false, foreign_key: true
      t.integer :position

      t.timestamps

      t.index [:connector_id, :context_id], unique: true
      t.index [:context_id, :connector_id], unique: true
    end
    add_index :connector_contexts, :position
  end
end
