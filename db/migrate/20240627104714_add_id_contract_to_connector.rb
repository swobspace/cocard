class AddIdContractToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :id_contract, :string, default: ''
    add_column :connectors, :serial, :string, default: ''
  end
end
