class CreateJoinTableConnectorClientCertificate < ActiveRecord::Migration[7.1]
  def change
    create_join_table :connectors, :client_certificates do |t|
      t.index [:connector_id, :client_certificate_id], unique: true
      t.index [:client_certificate_id, :connector_id], unique: true
    end
  end
end
