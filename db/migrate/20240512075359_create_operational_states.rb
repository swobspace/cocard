class CreateOperationalStates < ActiveRecord::Migration[7.1]
  def change
    create_table :operational_states do |t|
      t.string :name, null: false, default: ""
      t.string :description, default: ""

      t.timestamps
    end
  end
end
