class AddMoreCertSubjectsToCard < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :cert_subject_cn, :string, default: ""
    add_column :cards, :cert_subject_o, :string, default: ""
  end
end
