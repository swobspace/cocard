class AddSuccessBooleanToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :soap_request_success, :boolean, default: false
    add_column :connectors, :vpnti_online, :boolean, default: false
    change_column_default :connectors, :condition, from: 0, to: -1
  end
end
