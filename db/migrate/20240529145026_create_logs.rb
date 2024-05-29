class CreateLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :logs do |t|
      t.references :loggable, polymorphic: true, null: false
      t.string :action, default: ''
      t.timestamp :when
      t.string :level, default: ''
      t.text :message

      t.timestamps
    end
    add_index :logs, :level
  end
end
