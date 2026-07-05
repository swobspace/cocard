require 'rails_helper'

module Cocard
  RSpec.describe PinVerify, type: :model do
    let(:verify_pin_hash) do
      {:status=>
        {:result=>"Warning",
         :error=>
          {:message_id=>"f9505ccc-14f6-4826-ab88-09402b5a7881",
           :timestamp=>Time.current,
           :trace=>
            {:event_id=>"62a904a6-a5aa-47b9-a41b-4730a234d47f",
             :instance=>"Konnektor-Lokal",
             :log_reference=>nil,
             :comp_type=>"Konnektor",
             :code=>"4043",
             :severity=>"Warning",
             :error_type=>"Technical",
             :error_text=>"Timeout bei der PIN-Eingabe",
             :detail=>"Fehler bei VerifyPin des Kartendienstes"}}},
       :pin_result=>"ERROR",
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

    subject { Cocard::PinVerify.new(verify_pin_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::PinVerify.new() }.to raise_error(ArgumentError)
      end
    end

    describe "with real pin status" do
      it { expect(subject.pin_result).to eq("ERROR") }
      it { expect(subject.status).to eq("Warning") }
      it { expect(subject.error_text).to eq("Timeout bei der PIN-Eingabe") }
      it { expect(subject.left_tries).to eq(nil) }
    end

    describe "Cocard::PinVerify::ATTRIBUTES" do
      it { expect(Cocard::PinVerify::ATTRIBUTES).to contain_exactly(
             :pin_result, :status, :error_text, :left_tries ) }
    end
  end
end
