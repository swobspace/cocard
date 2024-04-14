require 'rails_helper'

module Cocard
  RSpec.describe Service, type: :model do
    let(:sds_file) { File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds') }
    let(:sds_string) { File.read(sds_file) }
    let(:hash) { Nori.new(strip_namespaces: true).parse(sds_string) }
    subject    { Cocard::Service.new(hash["ConnectorServices"]["ServiceInformation"]['Service'][0]) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::Service.new() }.to raise_error(ArgumentError)
      end
    end

    describe "#name" do
      it { expect(subject.name).to eq("NFDService") }
    end
   
    describe "#abstract" do
      it { expect(subject.abstract).to eq("NFD auf eGK verwalten") }
    end
   
    describe "#to_s" do
      it "shows product information summary" do
        expect(subject.to_s).to eq(<<~SVCINFO
          NFDService - NFD auf eGK verwalten
          SVCINFO
        )

      end
    end
  end
end
