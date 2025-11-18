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

    subject { RISE::TIClient::RemotePinPlus.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::RemotePinPlus) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:get_configurations)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::RemotePinPlus.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#get_configurations' do
      let(:configurations_body) do
        json =<<~EOKTS
          {
            "configurations": [
              {
                "card": {
                  "iccsn": "80276001731001234567",
                  "cardHolder": "Irgend eine Einrichtung",
                  "terminalId": "00:0D:F8:07:2C:B0",
                  "terminalHostname": "ORGA6100-01400123456789",
                  "cardType": "SMCB"
                },
                "status": "ACTIVE"
              }
            ]
          }
        EOKTS
      end

      let(:url) { tic.url + '/api/v1/premium/pin-plus' }
      before(:each) do
        WebMock.disable_net_connect!
        expect(subject).to receive(:api_token).at_least(:once)
                                              .and_return('eyJraWQiOiJkZGUyMDZiYi1lMDgz')
      end

      after(:each) do
        WebMock.allow_net_connect!
      end

      it "success: returns 200" do
        stub_request(:any, url).to_return(status: 200, body: configurations_body)

        called_back = false 
        subject.get_configurations do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to eq(JSON.parse(configurations_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "empty: returns 200" do
        stub_request(:any, url).to_return(status: 200, body: "")

        called_back = false 
        subject.get_configurations do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: 401" do
        stub_request(:any, url).to_return(status: 401)

        called_back = false 
        subject.get_configurations do |result|
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

    describe '#supported_cards' do
      let(:supported_cards_body) do
        json =<<~EOKTS
          {
            "cards": [
              {
                "card": {
                  "iccsn": "80276001731001234567",
                  "cardHolder": "Irgend eine Einrichtung",
                  "terminalId": "00:0D:F8:07:2C:B0",
                  "terminalHostname": "ORGA6100-01400123456789",
                  "cardType": "SMCB"
                },
                "state": "CONFIGURABLE"
              }
            ]
          }
        EOKTS
      end

      let(:url) { tic.url + '/api/v1/premium/pin-plus/supported-cards' }
      before(:each) do
        WebMock.disable_net_connect!
        expect(subject).to receive(:api_token).at_least(:once)
                                              .and_return('eyJraWQiOiJkZGUyMDZiYi1lMDgz')
      end

      after(:each) do
        WebMock.allow_net_connect!
      end

      it "success: returns 200" do
        stub_request(:any, url).to_return(status: 200, body: supported_cards_body)

        called_back = false 
        subject.supported_cards do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to eq(JSON.parse(supported_cards_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "empty: returns 200" do
        stub_request(:any, url).to_return(status: 200, body: "")

        called_back = false 
        subject.supported_cards do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: 401" do
        stub_request(:any, url).to_return(status: 401)

        called_back = false 
        subject.supported_cards do |result|
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
