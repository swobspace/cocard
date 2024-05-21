class AddAdminUrlToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :admin_url, :string, default: ""
  end
end
