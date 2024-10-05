#!/usr/bin/env ruby
# frozen_string_literal: true


ENV['RAILS_ENV'] ||= 'test'
require "#{File.dirname(__FILE__)}/../config/environment.rb"

p12file = Rails.root.join('spec', 'fixtures', 'files', 'demo.p12')
p12 = File.read(p12file)

pkcs12 = OpenSSL::PKCS12.new(p12, 'justfortesting')

certificate = pkcs12.certificate
pkey = pkcs12.key
puts pkey
puts pkey.private?

cipher = OpenSSL::Cipher.new 'aes-256-cbc'
passphrase = 'test99'
key_secure = pkey.export cipher, passphrase
open 'private.secure.pem', 'w' do |io|
  io.write key_secure
end
