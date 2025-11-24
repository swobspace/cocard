#!/usr/bin/env ruby
# frozen_string_literal: true


ENV['RAILS_ENV'] ||= 'development'
require "#{File.dirname(__FILE__)}/../config/environment.rb"

connector = Connector.where("name ILIKE ?", '%01-Spielwiese').first
client_certificate = ClientCertificate.where(client_system: 'cocard').first

cert_store = OpenSSL::X509::Store.new
cert_store.add_file "./utils/cacert.pem"

tls_options = {
  cert: client_certificate.certificate,
  key: client_certificate.private_key,
  cert_store: cert_store,
  verify_mode: (OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT),
  verify_hostname: false
}

ldap_options = {
  host: connector.ip.to_s,
  port: 636,
  base: "dc=data,dc=vzd",
  encryption: {
    method: :simple_tls,
    tls_options: tls_options
  }
}

ldap = Wobaduser::LDAP.new(ldap_options: ldap_options)

search = Wobaduser::User.search(ldap: ldap, 
                                filter: '(mail=chirurgie.sls@marienhaus.kim.telematik)')
puts search.success?
puts search.entries.count

entry = search.entries.first
puts entry.inspect


