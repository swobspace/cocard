class AddIndexToCardCertificates < ActiveRecord::Migration[8.1]
  def change
    add_index(:card_certificates, [:card_id, :cert_ref, :crypt], unique: true)
  end
end
