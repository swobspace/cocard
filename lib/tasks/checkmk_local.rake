namespace :checkmk do
  desc "create status output as checkmk local plugin"
  task :run => :environment do
    Connector.where('condition >= 0').each do |conn|
      puts %Q[#{conn.condition} "Connector: #{conn.name}" - #{conn.condition_message} (#{conn.ip}) #{Rails.application.routes.url_for(controller: :connectors, id: conn.id)}]
    end
    CardTerminal.where('condition >= 0').where('mac IS NOT NULL').each do |ct|
      puts %Q[#{ct.condition} "CardTerminal: #{ct.mac}" - #{ct.displayname} [#{ct.location&.lid}] serial:#{ct.serial} - #{ct.condition_message} (#{ct.ip}) #{Rails.application.routes.url_for(controller: :card_terminals, id: ct.id)}]
    end
    Card.where('condition >= 0').reject{|c| c.iccsn.blank? }.each do |card|
      puts %Q[#{card.condition} "#{card.card_type}: #{card.iccsn}" - #{card.card_holder_name} - #{card.condition_message} (Gültig bis: #{card.expiration_date}) #{Rails.application.routes.url_for(controller: :cards, id: card.id)}]
    end
  end
end
