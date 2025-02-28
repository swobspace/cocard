class UpdateShortNameToConnector < ActiveRecord::Migration[7.2]
  def change
    Connector.all.each do |conn|
      ip = conn.ip.to_s
      unless ip.blank?
        short_name = sprintf "K%02d", ip.split('.').last
        conn.update(short_name: short_name)
      end
    end
  end
end
