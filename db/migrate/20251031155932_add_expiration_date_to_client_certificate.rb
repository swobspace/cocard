class AddExpirationDateToClientCertificate < ActiveRecord::Migration[7.2]
  def up
    add_column :client_certificates, :expiration_date, :date
    ClientCertificate.reset_column_information
    ClientCertificate.all.each do |cert|
      cert.update_column(:expiration_date, cert.valid_until.to_date)
    end
  end

  def down
    remove_column :client_certificates, :expiration_date
  end
end
