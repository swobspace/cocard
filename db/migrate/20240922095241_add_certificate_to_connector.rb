class AddCertificateToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :iccsn, :string, default: ""
    add_column :connectors, :expiration_date, :date
  end
end
