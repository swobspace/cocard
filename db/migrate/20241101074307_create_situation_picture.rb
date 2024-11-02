class CreateSituationPicture < ActiveRecord::Migration[7.1]
  def change
    create_table :situation_picture do |t|
      t.timestamp :time
      t.string :ci, default: ''
      t.string :tid, default: ''
      t.string :bu, default: ''
      t.string :organization, default: ''
      t.string :pdt, default: ''
      t.string :product, default: ''
      t.integer :availability, default: 0
      t.string :comment, default: ''
      t.string :name, default: ''

      t.timestamps
    end
    add_index :situation_picture, :bu
    add_index :situation_picture, :pdt
    add_index :situation_picture, :availability
  end
end
