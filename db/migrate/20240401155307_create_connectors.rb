class CreateConnectors < ActiveRecord::Migration[7.1]
  def change
    create_table :connectors do |t|
      t.string :name, default: ""
      t.inet :ip, null: false
      t.string :sds_url, default: ""
      t.boolean :manual_update, default: false

      t.timestamps
    end
  end
end
