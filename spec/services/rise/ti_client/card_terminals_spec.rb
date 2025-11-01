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

    subject { RISE::TIClient::CardTerminals.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::CardTerminals) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:get_proxies)).to be_truthy }
      it { expect(subject.respond_to?(:get_proxy)).to be_truthy }
      it { expect(subject.respond_to?(:create_proxy)).to be_truthy }
      it { expect(subject.respond_to?(:update_proxy)).to be_truthy }
      it { expect(subject.respond_to?(:destroy_proxy)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::CardTerminals.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#get_proxies' do
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
        subject.get_proxies do |result|
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
        subject.get_proxies do |result|
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

    describe '#get_proxy' do
      let(:kt_proxy) do
        FactoryBot.create(:kt_proxy,
          uuid: "bf11726a-ad8f-11f0-8247-c025a5b36994",
          name: "ORGA6100-02412345678910",
          wireguard_ip: "198.52.100.1",
          incoming_ip: "192.0.2.1",
          incoming_port: 8080,
          outgoing_ip: "192.0.2.2",
          outgoing_port: 8080,
          card_terminal_ip: "192.0.2.100",
          card_terminal_port: 4742
        )
      end

      let(:proxy_body) do
        json =<<~EOKTPG
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
        EOKTPG
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

      it "success: gets proxy" do
        stubs.get('api/v1/manager/card-terminals/proxies/bf11726a-ad8f-11f0-8247-c025a5b36994') do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            proxy_body
          ]
        end

        called_back = false 
        subject.get_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to include(JSON.parse(proxy_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: 404 not found" do
        stubs.get('api/v1/manager/card-terminals/proxies/bf11726a-ad8f-11f0-8247-c025a5b36994') do
          [
            404, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.get_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_notfound do |message|
            called_back = :notfound
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:notfound)
      end

      it "failure: 500 internal server error" do
        stubs.get('api/v1/manager/card-terminals/proxies/bf11726a-ad8f-11f0-8247-c025a5b36994') do
          [
            500, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.get_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:failure)
      end
    end

    describe '#create_proxy' do
      let(:kt_proxy) do
        FactoryBot.create(:kt_proxy,
          uuid: "bf11726a-ad8f-11f0-8247-c025a5b36994",
          name: "ORGA6100-02412345678910",
          wireguard_ip: "198.52.100.1",
          incoming_ip: "192.0.2.1",
          incoming_port: 8080,
          outgoing_ip: "192.0.2.2",
          outgoing_port: 8080,
          card_terminal_ip: "192.0.2.100",
          card_terminal_port: 4742
        )
      end

      let(:proxy_body) do
        json =<<~EOKTPC.gsub(/[ \n]/, '')
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
        EOKTPC
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

      it "success: creates proxy" do
        stubs.post(
          'api/v1/manager/card-terminals/proxies',
          proxy_body,
          "Content-Type" => "application/json"
        ) do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            proxy_body
          ]
        end

        called_back = false 
        subject.create_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to include(JSON.parse(proxy_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: no content" do
        stubs.post(
          'api/v1/manager/card-terminals/proxies',
          proxy_body,
          "Content-Type" => "application/json"
        ) do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.create_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:failure)
      end
    end

    describe '#update_proxy' do
      let(:kt_proxy) do
        FactoryBot.create(:kt_proxy,
          uuid: "bf11726a-ad8f-11f0-8247-c025a5b36994",
          name: "ORGA6100-02412345678910",
          wireguard_ip: "198.52.100.1",
          incoming_ip: "192.0.2.1",
          incoming_port: 8080,
          outgoing_ip: "192.0.2.2",
          outgoing_port: 8080,
          card_terminal_ip: "192.0.2.100",
          card_terminal_port: 4742
        )
      end

      let(:proxy_body) do
        json =<<~EOKTPG
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
        EOKTPG
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

      it "success: update proxy" do
        stubs.post('api/v1/manager/card-terminals/proxies/bf11726a-ad8f-11f0-8247-c025a5b36994') do
          [ 204, {}, {} ]
        end

        called_back = false 
        subject.update_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: 404 not found" do
        stubs.post('api/v1/manager/card-terminals/proxies/bf11726a-ad8f-11f0-8247-c025a5b36994') do
          [ 404, {}, {} ]
        end

        called_back = false 
        subject.update_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_notfound do |message|
            called_back = :notfound
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:notfound)
      end

      it "failure: 500 internal server error" do
        stubs.post('api/v1/manager/card-terminals/proxies/bf11726a-ad8f-11f0-8247-c025a5b36994') do
          [ 500, {}, {} ]
        end

        called_back = false 
        subject.update_proxy(kt_proxy) do |result|
          result.on_success do |message, value|
            called_back = :success
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
