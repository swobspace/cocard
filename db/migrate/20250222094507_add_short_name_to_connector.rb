class AddShortNameToConnector < ActiveRecord::Migration[7.2]
  def change
    add_column :connectors, :short_name, :string, default: ''
  end
end
