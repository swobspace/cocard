class AddTIClientIdToKTProxy < ActiveRecord::Migration[7.2]
  def change
    add_reference :kt_proxies, :ti_client, null: false, foreign_key: true
  end
end
