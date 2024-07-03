namespace :checkmk do
  desc "create status output as checkmk local plugin"
  task :run => :environment do
    Connector.where('condition >= 0').each do |conn|
      puts %Q[#{conn.condition} "Connector: #{conn.name}" "state=#{conn.condition} #{conn.condition_message} (#{conn.ip}) #{Rails.application.routes.url_helpers.connector_url(conn.id)}]
    end
    CardTerminal.where('condition >= 0').where('mac IS NOT NULL').each do |ct|
      puts %Q[#{ct.condition} "CardTerminal: #{ct.mac}" "state=#{ct.condition}" #{ct.connector&.name} #{ct.displayname} [#{ct.location&.lid}] serial:#{ct.serial} - #{ct.condition_message} (#{ct.ip}) #{Rails.application.routes.url_helpers.card_terminal_url(ct.id)}]
    end
    Card.where('condition >= 0').reject{|c| c.iccsn.blank? }.each do |card|
      puts %Q[#{card.condition} "#{card.card_type}: #{card.iccsn}" "state=#{card.condition} #{card.card_terminal&.connector&.name} #{card.card_holder_name} - #{card.condition_message} (Gültig bis: #{card.expiration_date}) #{Rails.application.routes.url_helpers.card_url(card.id)}]
    end
  end
end
