require 'rails_helper'

module Cocard
  RSpec.describe SDS, type: :model do
    let(:sds_file) { File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds') }
    let(:sds_string)      { File.read(sds_file) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::SDS.new() }.to raise_error(ArgumentError)
      end
    end
   
    describe "with connector.sds" do
      let(:sds) { Cocard::SDS.new(sds_string) }
      it "parses the xml file" do
        expect(sds.hash.keys).to contain_exactly('ConnectorServices')
        expect(sds.hash['ConnectorServices'].keys).to include(
          "ProductInformation",
          "TLSMandatory",
          "ClientAutMandatory",
          "ServiceInformation",
          "@xmlns"
        )
      end
    end


  end
end
