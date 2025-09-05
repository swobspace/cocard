class CreateKTProxies < ActiveRecord::Migration[7.2]
  def change
    create_table :kt_proxies do |t|
      t.belongs_to :card_terminal
      t.string :uuid, null: false
      t.string :name, default: ''
      t.inet :wireguard_ip
      t.inet :incoming_ip
      t.integer :incoming_port
      t.inet :outgoing_ip
      t.integer :outgoing_port
      t.inet :card_terminal_ip
      t.integer :card_terminal_port, default: 4742

      t.timestamps
    end
  end
end
