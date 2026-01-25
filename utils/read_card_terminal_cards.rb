#!/usr/bin/env ruby
# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'development'
require "#{File.dirname(__FILE__)}/../config/environment.rb"
require 'optparse'

crypt = 'ECC'

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options] card_terminal_id"
  opts.on("-c", "--crypt RSA|ECC", "crypt algorithm") do |c|
    crypt = c
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
  end

end.parse!

if ARGV.empty?
  puts "Usage: #{__FILE__} card_terminal_id"
  exit 1
else
  card_terminal_id = ARGV[0]
end

ct        = CardTerminal.find card_terminal_id
connector = ct.connector
ctx       = connector.contexts.first
puts "CardTerminal: #{ct.name} - #{ct.mac}"

# -- get Cards
result = Cocard::GetCards.new(connector: connector, 
                                context: ctx,
                                ct_id: ct.ct_id)
                         .call

unless result.success?
  puts result.inspect
  exit 1
end
# pp result.cards

# -- collect Cards
cards = []
result.cards.each do |cc|
  creator = Cards::Creator.new(connector: connector, cc: cc, context: ctx)
  if creator.save
    cards << creator.card
  end
end

cards.each do |card|
  printf "\n#{card.card_type}: #{card.to_s}\n"

  Cards::FetchCertificates.new(card: card).call do |result|

    result.on_success do |message, card_certificates|
      puts message
      card_certificates.each do |crt|
        puts "=== Crypt: #{crt.crypt}, CertRef: #{crt.cert_ref} ==="
        puts crt.issuer
        puts crt.serial_number
        puts crt.subject_name
        puts crt.expiration_date
      end
    end

    result.on_failure do |message|
      puts message
    end
  end
end

