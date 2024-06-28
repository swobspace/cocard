class AddClientSystemToClientCertificate < ActiveRecord::Migration[7.1]
  def change
    add_column :client_certificates, :client_system, :string, default: ""
  end
end
