namespace :checkmk do
  desc "create status output as checkmk local plugin"
  task :run => :environment do
    Connector.where('condition >= 0').each do |conn|
      puts %Q[#{conn.condition} "Connector: #{conn.name}" - #{conn.condition_message} (#{conn.ip})]
    end
    CardTerminal.where('condition >= 0').each do |ct|
      puts %Q[#{ct.condition} "CardTerminal: #{ct.name}" - #{ct.condition_message} (#{ct.ip})]
    end
    Card.where('condition >= 0').each do |card|
      puts %Q[#{card.condition} "#{card.card_type}: #{card.card_holder_name}" - #{card.condition_message} (#{card.iccsn})]
    end
  end
end
