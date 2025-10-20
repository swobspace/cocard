# frozen_string_literal: true

require 'rails_helper'
module RISE
  RSpec.describe TIClient do
    let(:tic) do
      FactoryBot.create(:ti_client,
        name: "TIC01",
        url: ENV['TIC_URL']
      )
    end

    let(:json_token) do
      '{
        "access_token": "eyJraWQiOiJkZGUyMDZiYi1lMDgz",
        "scope": "API",
        "token_type": "Bearer",
        "expires_in": 299
      }'
    end

    subject { RISE::TIClient.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:api_token)).to be_truthy }
      it { expect(subject.respond_to?(:authorization)).to be_truthy }
      it { expect(subject.respond_to?(:authenticate)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::Token.new()
          end.to raise_error(ArgumentError)
        end
      end
    end

    describe '#authenticate' do
      let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
      let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
      let(:auth_param) {{
        client_id: ENV['TIC_APP'],
        client_secret: ENV['TIC_SECRET'],
        scope: 'API',
        grant_type: 'client_credentials'
      }}

      before(:each) do
        allow(Faraday).to receive(:new).and_return(conn)
      end

      after(:each) do
        Faraday.default_connection = nil
      end

      it "success: gets bearer token" do
        stubs.post('oauth2/token', auth_param) do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            json_token
          ]
        end

        expect(subject.authorization).to be_kind_of(RISE::TIClient::Token)
        expect(subject.api_token).to eq("eyJraWQiOiJkZGUyMDZiYi1lMDgz")
      end

      it "failure: no bearer token" do
        stubs.post('oauth2/token', auth_param) do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            '{ "error": "invalid_client" }'
          ]
        end

        expect(subject.authorization).to be_nil
        expect(subject.api_token).to be_nil
      end
    end

    describe '#get_card_terminal_proxies' do
      let(:card_terminal_proxies_body) do
        json =<<~EOKTPB
          {
            "proxies": [
              {
                "id": "bf11726a-ad8f-11f0-8247-c025a5b36994",
                "name": "ORGA6100-02412345678910",
                "wireguardIp": "198.52.100.1",
                "incomingIp": "192.0.2.1",
                "incomingPort": 8080,
                "outgoingIp": "192.0.2.2",
                "outgoingPort": 8080,
                "cardTerminalIp": "192.0.2.100",
                "cardTerminalPort": 4742
              }
            ]
          }
        EOKTPB
      end
      let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
      let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
      before(:each) do
        allow(Faraday).to receive(:new).and_return(conn)
        expect(subject).to receive(:api_token).at_least(:once)
                                              .and_return('eyJraWQiOiJkZGUyMDZiYi1lMDgz')
      end

      after(:each) do
        Faraday.default_connection = nil
      end

      it "success: gets card terminal proxies" do
        stubs.get('api/v1/manager/card-terminals/proxies') do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            card_terminal_proxies_body
          ]
        end

        called_back = false 
        subject.get_card_terminal_proxies do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to include(JSON.parse(card_terminal_proxies_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: no content" do
        stubs.get('api/v1/manager/card-terminals/proxies') do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.get_card_terminal_proxies do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to include(JSON.parse(card_terminal_proxies_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:failure)
      end
    end
  end
end

