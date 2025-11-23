#!/usr/bin/env ruby
# frozen_string_literal: true


ENV['RAILS_ENV'] ||= 'development'
require "#{File.dirname(__FILE__)}/../config/environment.rb"

connector = Connector.where("name ILIKE ?", '%01-Spielwiese').first
client_certificate = ClientCertificate.where(client_system: 'cocard').first

puts connector
puts client_certificate

cert_store = OpenSSL::X509::Store.new
cert_store.add_file "./utils/cacert.pem"
io = TCPSocket.new(connector.ip.to_s, "636")
ctx = OpenSSL::SSL::SSLContext.new
ctx.cert = client_certificate.certificate
ctx.key = client_certificate.private_key
ctx.verify_hostname = false
# ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
ctx.cert_store = cert_store
conn = OpenSSL::SSL::SSLSocket.new(io, ctx)
conn.connect

