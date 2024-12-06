class AddBasicAuthToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :auth_user, :string, default: ""
    add_column :connectors, :auth_password, :string, default: ""
  end
end
