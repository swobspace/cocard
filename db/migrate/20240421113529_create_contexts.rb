class CreateContexts < ActiveRecord::Migration[7.1]
  def change
    create_table :contexts do |t|
      t.string :mandant, null: false
      t.string :client_system, null: false
      t.string :workplace, null: false
      t.string :description, default: ""

      t.timestamps
    end
  end
end
