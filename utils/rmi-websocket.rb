#!/usr/bin/env ruby
# frozen_string_literal: true

require 'faye/websocket'
require 'eventmachine'

ENV['RAILS_ENV'] ||= 'test'
require "#{File.dirname(__FILE__)}/../config/environment.rb"

url = "wss://#{ENV['CT_IP']}"

EM.run {
  ws = Faye::WebSocket::Client.new(url, [], {
           ping: 15,
           tls: {verify_peer: false}
         }
       )

  ws.on :open do |event|
    p [:open]
    # ws.send({
    #           "request" => {
    #             "token": SecureRandom.uuid.to_s,
    #             "service": "Api",
    #             "method": { "getVersionInfo": {} }
    #           }
    #         }.to_json)
    ws.send({
              "request" => {
                "token": SecureRandom.uuid.to_s,
                "service": "Auth",
                "method": { 
                  "basicAuth": {
                    "user": ENV['WS_AUTH_USER'],
                    "credentials": ENV['WS_AUTH_PASS']
                  } 
                }
              }
            }.to_json)
  end

  ws.on :message do |event|
    p [:message]
    pp JSON.parse(event.data)
    ws.close
  end

  ws.on :error do |event|
    p [:error, event.message]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
    EM.stop
  end
}

puts "this is outside EM.run"
