class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards do |t|
      t.string :name, default: ''

      t.timestamps
    end
  end
end
