class AddClientSecretToTIClient < ActiveRecord::Migration[7.2]
  def change
    add_column :ti_clients, :client_secret, :string
  end
end
