class CreateCardCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :card_certificates do |t|
      t.belongs_to :card, null: false, foreign_key: true
      t.string :crypt, default: ""
      t.string :cert_ref, default: ""
      t.text :issuer
      t.string :serial_number, default: ""
      t.text :subject_name
      t.text :certificate
      t.date :expiration_date

      t.timestamps
    end
  end
end
