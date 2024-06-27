class AddAuthenticationToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :use_tls, :boolean, default: false
    add_column :connectors, :authentication, :integer, default: 0
  end
end
