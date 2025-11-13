# frozen_string_literal: true

require 'rails_helper'
module RISE
  RSpec.describe TIClient::Konnektor::Terminal do
    let!(:ct) { FactoryBot.create(:card_terminal, mac: '00:0D:F8:08:77:76') }
    let(:bekannt) {{
      "ACTIVEROLE" => nil,
      "ADMIN_USERNAME" => "admin",
      "CONNECTED" => false,
      "CORRELATION" => "BEKANNT",
      "CTID" => "00:0D:F8:08:77:76",
      "EHEALTH_INTERFACE_VERSION": "1.0.0",
      "HOSTNAME" => "ORGA6100-0142000000DABD",
      "IP_ADDRESS" => "172.16.55.29",
      "IS_PHYSICAL" => true,
      "MAC_ADDRESS" => "00:0D:F8:08:77:76",
      "PRODUCTINFORMATION" => nil,
      "SLOTCOUNT" => 4,
      "SLOTS_USED" => [],
      "SMKT_AUT" => nil,
      "TCP_PORT" => 8273,
      "VALID_VERSION" => true
    }}
    let(:active) {{
      "ACTIVEROLE" => "USER",
      "ADMIN_USERNAME" => "",
      "CONNECTED" => true,
      "CORRELATION" => "AKTIV",
      "CTID" => "00:0D:F8:05:39:6D",
      "EHEALTH_INTERFACE_VERSION" => "1.0.0",
      "HOSTNAME" => "ORGA6100-0141000001868E",
      "IP_ADDRESS" => "172.16.55.29",
      "IS_PHYSICAL" => true,
      "MAC_ADDRESS" => "00:0D:F8:05:39:6D",
      "PRODUCTINFORMATION" => {
        "fwVersionLocal" => "3.9.2",
        "hwVersionLocal" => "1.2.0",
        "informationDate" => "2025-10-31T08:09:12.250100904",
        "productCode" => "ORGA6100",
        "productName" => "ORGA6100",
        "productType" => "KT",
        "productTypeVersion" => "1.8.0",
        "productVendorID" => "INGHC",
        "productVendorName" => "INGHC"
      },
      "SLOTCOUNT" => 4,
      "SLOTS_USED" => [
        4
      ],
      "SMKT_AUT" => "some stuff about certificates", 
      "TCP_PORT" => 8278,
      "VALID_VERSION" => true
    }}

    subject { RISE::TIClient::Konnektor::Terminal.new(bekannt) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::Konnektor::Terminal) }
      it { expect(subject.respond_to?(:correlation)).to be_truthy }
      it { expect(subject.respond_to?(:connected)).to be_truthy }
      it { expect(subject.respond_to?(:mac)).to be_truthy }
      it { expect(subject.respond_to?(:ct_id)).to be_truthy }
      it { expect(subject.respond_to?(:name)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::Konnektor::Terminal.new()
          end.to raise_error(ArgumentError)
        end
      end

      context "with data" do
        it { expect(subject.correlation).to eq("BEKANNT") }
        it { expect(subject.connected).to be_falsey }
        it { expect(subject.ct_id).to eq("00:0D:F8:08:77:76") }
        it { expect(subject.mac).to eq("00:0D:F8:08:77:76") }
        it { expect(subject.name).to eq("ORGA6100-0142000000DABD") }
        it { expect(subject.tcp_port).to eq(8273) }
        it { expect(subject.card_terminal.id).to eq(ct.id) }
      end
    end
  end
end

