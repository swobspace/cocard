require 'rails_helper'

module Cocard
  RSpec.describe CertificateExpiration, type: :model do
    let!(:ts) { 1.day.before(Time.current) }

    subject { Cocard::CertificateExpiration.new(expiration_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::CertificateExpiration.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty card" do
      it "returns nil" do
        expect { Cocard::CertificateExpiration.new(nil) }.not_to raise_error
      end
    end

    describe "Cocard::CertificateExpiration::ATTRIBUTES" do
      it { expect(Cocard::CertificateExpiration::ATTRIBUTES).to contain_exactly(:properties, :iccsn, :expiration_date, :ct_id, :card_handle ) }
    end

    describe "with card expiration data" do
      let(:expiration_hash) do
       {:ct_id=>"CT_ID_0176",
        :card_handle=>"20e81a27-92ce-4af0-b709-db8ac14c601b",
        :iccsn=>"80276003550000469999",
        :subject_common_name=>"Doctor Who's Universe",
        :serial_number=>"4613338",
        :validity=> 1.year.after(Date.current)}
      end

      describe "with real card" do
        it { expect(subject.properties).to eq(expiration_hash) }
        it { expect(subject.card_handle).to eq("20e81a27-92ce-4af0-b709-db8ac14c601b") }
        it { expect(subject.iccsn).to eq("80276003550000469999")}
        it { expect(subject.ct_id).to eq("CT_ID_0176")}
        it { expect(subject.expiration_date).to eq(1.year.after(Date.current))}
        it { expect(subject.is_connector_cert).to be_falsey }
      end
    end

    describe "with connector cert expiration data" do
      let(:expiration_hash) do
       {:ct_id=>nil,
        :card_handle=>nil,
        :iccsn=>"80276003640000999999",
        :subject_common_name=>"80276003640000999999-20200224",
        :serial_number=>"1469298",
        :validity=> 1.year.after(Date.current)}
      end

      describe "with real card" do
        it { expect(subject.properties).to eq(expiration_hash) }
        it { expect(subject.card_handle).to be_nil }
        it { expect(subject.iccsn).to eq("80276003640000999999")}
        it { expect(subject.ct_id).to be_nil }
        it { expect(subject.expiration_date).to eq(1.year.after(Date.current))}
        it { expect(subject.is_connector_cert).to be_truthy }
      end
    end

  end
end
