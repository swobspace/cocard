require 'rails_helper'

module Cocard
  RSpec.describe ProductInformation, type: :model do

    describe "with connector sds product information" do
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

      describe "#firmware_version" do
        it { expect(subject.firmware_version).to eq('5.1.8') }
      end

      describe "#product_code" do
        it { expect(subject.product_code).to eq('kocobox') }
      end

      describe "#product_vendor_id" do
        it { expect(subject.product_vendor_id).to eq('KOCOC') }
      end

      describe "#to_s" do
        it "shows product information summary" do
          expect(subject.to_s).to eq(<<~PRODINFO.chomp
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

    describe "with card terminal product information" do
      let(:ts) { Time.current }
      let(:prod_info_hash) do
        {:information_date=>ts,
         :product_type_information=>
          {:product_type=>"KT", :product_type_version=>"1.5.0"},
         :product_identification=>
          {:product_vendor_id=>"INGHC",
           :product_code=>"ORGA6100",
           :product_version=>{:local=>{:hw_version=>"1.2.0", :fw_version=>"3.8.2"}}},
         :product_miscellaneous=>{:product_vendor_name=>nil, :product_name=>nil}}
      end
      subject { Cocard::ProductInformation.new(prod_info_hash) }

      describe "#firmware_version" do
        it { expect(subject.firmware_version).to eq('3.8.2') }
      end

      describe "#product_code" do
        it { expect(subject.product_code).to eq('ORGA6100') }
      end

      describe "#to_s" do
        it "shows product information summary" do
          expect(subject.to_s).to eq(<<~PRODINFO.chomp
            ProduktTypeInformation:
              ProductType: KT
              ProductTypeVersion: 1.5.0

            ProductIdentification:
              ProductVendorID: INGHC
              ProductCode: ORGA6100
              ProductVersion:
                Local:
                  HWVersion: 1.2.0
                  FWVersion: 3.8.2

            ProductMiscellaneous:
              ProductVendorName: 
              ProductName: 

            #{ts}
           PRODINFO
         )

        end

      end
    end
  end
end
