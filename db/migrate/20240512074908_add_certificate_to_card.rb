class AddCertificateToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :certificate, :text
    add_column :cards, :cert_subject_title, :string, default: ""
    add_column :cards, :cert_subject_sn, :string, default: ""
    add_column :cards, :cert_subject_givenname, :string, default: ""
    add_column :cards, :cert_subject_street, :string, default: ""
    add_column :cards, :cert_subject_postalcode, :string, default: ""
    add_column :cards, :cert_subject_l, :string, default: ""
  end
end
