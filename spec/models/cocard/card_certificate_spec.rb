require 'rails_helper'

module Cocard
  RSpec.describe CardCertificate, type: :model do
    let(:card_cert_yml) {
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'read_card_certificate_response.yml')
      File.read(file)
    }
    let(:card_cert_hash) do 
      YAML.unsafe_load(card_cert_yml)
          .dig(:read_card_certificate_response, :x509_data_info_list, :x509_data_info)
    end

    subject { Cocard::CardCertificate.new(card_cert_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::CardCertificate.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty certificate" do
      it "returns nil" do
        expect { Cocard::CardCertificate.new(nil) }.to raise_error(NoMethodError)
      end
    end
   
    describe "with real card certificate" do
      it { expect(subject.cert_ref).to eq("C.AUT") }
      it { expect(subject.issuer).to eq("CN=D-Trust.SMCB-CA3,OU=Institution des Gesundheitswesens-CA der Telematikinfrastruktur,O=D-TRUST GmbH,C=DE") }
      it { expect(subject.serial_number).to eq("4683251") }
      it { expect(subject.subject_name).to be_nil }
      it { expect(subject.certificate).to be_kind_of OpenSSL::X509::Certificate }
      it { expect(subject.expiration_date).to eq("2026-08-15") }
    end

    describe "Cocard::CardCertificate::ATTRIBUTES" do
      it { expect(Cocard::CardCertificate::ATTRIBUTES).to contain_exactly(:cert_ref,
             :issuer, :serial_number, :subject_name, :certificate, :expiration_date ) }
    end
  end
end
