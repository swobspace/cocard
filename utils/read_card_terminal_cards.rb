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

cards.each do |c|
  printf "\n#{c.card_type}: #{c.to_s}\n"
  if c.card_type == 'SMC-B'
    cert_ref_list = %w( C.AUT C.ENC C.SIG )
  elsif c.card_type == 'HBA'
    cert_ref_list = %w( C.AUT C.ENC C.QES)
  else
    puts "... skipping"
    next
  end
  result = Cocard::SOAP::ReadCardCertificate.new(
             card_handle: c.card_handle,
             connector: connector,
             mandant: ctx&.mandant,
             client_system: ctx&.client_system,
             workplace: ctx&.workplace,
             cert_ref_list: cert_ref_list,
             crypt: crypt,
             user_id: 'cocard'
           ).call
  unless result.success?
    puts result
    next
  end
  data_infos = Array(result.response.dig(:read_card_certificate_response, 
                                         :x509_data_info_list, :x509_data_info))
  data_infos.each do |di|
    crt = Cocard::CardCertificate.new(di)
    puts "=== CertRef: #{crt.cert_ref} ==="
    puts crt.certificate.to_text
  end
  puts ""
end

