require 'rails_helper'

RSpec.describe "TIClients::Terminals", type: :request do
  let(:tic) { FactoryBot.create(:ti_client, url: 'http://127.1.2.3', client_secret: "bla") }
  let(:rtic) { instance_double(RISE::TIClient::Konnektor::Terminals) }
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

  before(:each) do
    login_admin
  end

  describe "GET /terminals" do
    let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
    let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
    before(:each) do
      allow(Faraday).to receive(:new).and_return(conn)
      expect_any_instance_of(RISE::TIClient::Konnektor::Terminals).to receive(:api_token).at_least(:once).and_return('eyJraWQiOiJkZGUyMDZiYi1lMDgz')
    end

    after(:each) do
      Faraday.default_connection = nil
    end

    it "returns http success" do
        stubs.get('api/v1/konnektor/default/api/v1/ctm/state') do
          [
            200,
            {'Content-Type': 'application/json;charset=UTF-8'},
            terminals_body
          ]
        end

      get ti_client_terminals_path(tic)
      expect(response).to have_http_status(:success)
    end
  end

end
