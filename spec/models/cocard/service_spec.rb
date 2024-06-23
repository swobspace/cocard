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

    describe "#version(1.0.0)" do
      it { expect(subject.version('1.0.0')).to be_kind_of(Hash) }
      it { expect(subject.version('1.0.0').keys).to contain_exactly(
            "version", "abstract", "endpoint", "endpoint_tls", "target_namespace"
           ) }
    end

    describe "#endpoint_location" do
      it { expect(subject.endpoint_location('1.0.0')).to eq(
                  "http://10.200.149.3:80/service/fm/nfdm/nfdservice") }
    end

    describe "#endpoint_tls_location" do
      it { expect(subject.endpoint_tls_location('1.0.0')).to eq(
                  "https://10.200.149.3:443/service/fm/nfdm/nfdservice") }
    end

    describe "#target_namespace" do
      it { expect(subject.target_namespace('1.0.0')).to eq(
                  "http://ws.gematik.de/conn/nfds/NFDService/WSDL/v1.0") }
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
