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

    subject { RISE::TIClient::Konnektor::Terminals.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::Konnektor::Terminals) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:get_terminals)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::Konnektor::Terminals.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#get_terminals' do
      let(:terminals_body) do
        json =<<~EOKTS
          {
            "CTM_SUPPORTED_KT_VERSIONS": [
              "1.0.0"
            ],
            "CTM_CT_LIST": [
              {
                "ACTIVEROLE": null,
                "ADMIN_USERNAME": "admin",
                "CONNECTED": false,
                "CORRELATION": "BEKANNT",
                "CTID": "00:0D:F8:08:77:76",
                "EHEALTH_INTERFACE_VERSION": "1.0.0",
                "HOSTNAME": "ORGA6100-0142000000DABD",
                "IP_ADDRESS": "172.16.55.29",
                "IS_PHYSICAL": true,
                "MAC_ADDRESS": "00:0D:F8:08:77:76",
                "PRODUCTINFORMATION": null,
                "SLOTCOUNT": 4,
                "SLOTS_USED": [],
                "SMKT_AUT": null,
                "TCP_PORT": 8273,
                "VALID_VERSION": true
              },
             {
                "ACTIVEROLE": "USER",
                "ADMIN_USERNAME": "",
                "CONNECTED": true,
                "CORRELATION": "AKTIV",
                "CTID": "00:0D:F8:05:39:6D",
                "EHEALTH_INTERFACE_VERSION": "1.0.0",
                "HOSTNAME": "ORGA6100-0141000001868E",
                "IP_ADDRESS": "172.16.55.29",
                "IS_PHYSICAL": true,
                "MAC_ADDRESS": "00:0D:F8:05:39:6D",
                "PRODUCTINFORMATION": {
                  "fwVersionLocal": "3.9.2",
                  "hwVersionLocal": "1.2.0",
                  "informationDate": "2025-10-31T08:09:12.250100904",
                  "productCode": "ORGA6100",
                  "productName": "ORGA6100",
                  "productType": "KT",
                  "productTypeVersion": "1.8.0",
                  "productVendorID": "INGHC",
                  "productVendorName": "INGHC"
                },
                "SLOTCOUNT": 4,
                "SLOTS_USED": [
                  4
                ],
                "SMKT_AUT": "some stuff about certificates", 
                "TCP_PORT": 8278,
                "VALID_VERSION": true
              }
            ]
          }
        EOKTS
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
        stubs.get('api/v1/konnektor/default/api/v1/ctm/state') do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            terminals_body
          ]
        end

        called_back = false 
        subject.get_terminals do |result|
          result.on_success do |message, value|
            called_back = :success
            expect(value).to include(JSON.parse(terminals_body))
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure: not activated" do
        stubs.get('api/v1/konnektor/default/api/v1/ctm/state') do
          [
            403, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.get_terminals do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_access_denied do |message|
            called_back = :access_denied
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:access_denied)
      end

      it "failure: no content" do
        stubs.get('api/v1/konnektor/default/api/v1/ctm/state') do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.get_terminals do |result|
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

    describe '#discover' do
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

      it "success: returns 200" do
        stubs.post('api/v1/konnektor/default/api/v1/ctm/terminals/discover') do
          [
            200,
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.discover do |result|
          result.on_success do |message, value|
            called_back = :success
          end
          result.on_failure do |message|
            called_back = :failure
          end
        end
        expect(called_back).to eq(:success)
      end

      it "failure" do
        stubs.post('api/v1/konnektor/default/api/v1/ctm/terminals/discover') do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            ''
          ]
        end

        called_back = false 
        subject.discover do |result|
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
