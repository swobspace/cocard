#!/usr/bin/env ruby
# frozen_string_literal: true


ENV['RAILS_ENV'] ||= 'test'
require "#{File.dirname(__FILE__)}/../config/environment.rb"

connector = Connector.where("name ILIKE ?", '%01-Spielwiese').first
client_certificate = ClientCertificate.where(client_system: 'cocard').first

tls_options = {
  cert: client_certificate.certificate,
  key: client_certificate.private_key,
  ca_path: '/etc/pki/ca-trust/extracted/openssl',
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
  verify_hostname: false
}

ldap_options = {
  host: connector.ip.to_s,
  port: 636,
  base: "dc=data,dc=vzd",
  encryption: :simple_tls,
  tls_options: tls_options
}

ldap = Wobaduser::LDAP.new(ldap_options: ldap_options)

search = Wobaduser::User.search(ldap: ldap, 
                                filter: '(mail=chirurgie.sls@marienhaus.kim.telematik)')
search.success?
search.entries.count
search.entries
entry = search.entries.first


