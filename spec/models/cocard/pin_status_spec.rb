require 'rails_helper'

module Cocard
  RSpec.describe PinStatus, type: :model do
    let(:pin_status_hash) do
      {:status=>{:result=>"OK"},
       :pin_status=>"VERIFIABLE",
       :left_tries=>"3",
       :"@xmlns:ns2"=>"http://ws.gematik.de/conn/ConnectorCommon/v5.0",
       :"@xmlns:ns3"=>"http://ws.gematik.de/tel/error/v2.0",
       :"@xmlns:ns4"=>"urn:oasis:names:tc:dss:1.0:core:schema",
       :"@xmlns:ns5"=>"http://www.w3.org/2000/09/xmldsig#",
       :"@xmlns:ns6"=>"http://ws.gematik.de/conn/CardServiceCommon/v2.0",
       :"@xmlns:ns7"=>"http://ws.gematik.de/conn/CardService/v8.1",
       :"@xmlns:ns8"=>"http://ws.gematik.de/conn/ConnectorContext/v2.0",
       :"@xmlns:ns9"=>"http://ws.gematik.de/int/version/ProductInformation/v1.1",
       :"@xmlns:ns10"=>"urn:oasis:names:tc:SAML:1.0:assertion"}
    end

    subject { Cocard::PinStatus.new(pin_status_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::PinStatus.new() }.to raise_error(ArgumentError)
      end
    end

    describe "with real pin status" do
      it { expect(subject.pin_status).to eq("VERIFIABLE") }
      it { expect(subject.left_tries).to eq("3") }
    end

    describe "Cocard::PinStatus::ATTRIBUTES" do
      it { expect(Cocard::PinStatus::ATTRIBUTES).to contain_exactly(
             :pin_status, :left_tries ) }
    end
  end
end
