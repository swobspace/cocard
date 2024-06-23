class CreateClientCertificates < ActiveRecord::Migration[7.1]
  def change
    create_table :client_certificates do |t|
      t.string :name, default: ""
      t.text :cert
      t.text :pkey
      t.string :passphrase, default: ""

      t.timestamps
    end
  end
end
