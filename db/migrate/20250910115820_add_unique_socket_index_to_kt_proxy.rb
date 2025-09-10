class AddUniqueSocketIndexToKTProxy < ActiveRecord::Migration[7.2]
  def change
    add_index :kt_proxies, [:incoming_ip, :incoming_port], unique: true, name: 'in_socket'
    add_index :kt_proxies, [:outgoing_ip, :outgoing_port], unique: true, name: 'out_socket'
  end
end
