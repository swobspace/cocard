require 'rails_helper'

module Cocard
  RSpec.describe ProductInformation, type: :model do
    let(:sds_file) { File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds') }
    let(:sds_string) { File.read(sds_file) }
    let(:hash) { Nori.new(strip_namespaces: true).parse(sds_string) }
    subject    { Cocard::ProductInformation.new(hash["ConnectorServices"]["ProductInformation"]) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::ProductInformation.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty connector_services" do
      it "returns nil" do
        expect { Cocard::ProductInformation.new(nil) }.not_to raise_error
      end
    end
   
    describe "#to_s" do
      it "shows product information summary" do
        expect(subject.to_s).to eq(<<~PRODINFO
          ProduktTypeInformation:
            ProductType: Konnektor
            ProductTypeVersion: 5.1.0

          ProductIdentification:
            ProductVendorID: KOCOC
            ProductCode: kocobox
            ProductVersion:
              Local:
                HWVersion: 2.0.0
                FWVersion: 5.1.8

          ProductMiscellaneous:
            ProductVendorName: KoCo Connector
            ProductName: KoCoBox MED+

          2024-04-13T10:36:01+02:00
         PRODINFO
       )

      end
    end


  end
end
