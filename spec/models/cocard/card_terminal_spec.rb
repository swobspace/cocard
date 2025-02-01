require 'rails_helper'

module Cocard
  RSpec.describe CardTerminal, type: :model do
    let!(:ts) { 1.day.before(Time.current) }
    let(:card_terminal_hash) do
      {:product_information=>
         {:information_date=>ts,
          :product_type_information=>
           {:product_type=>"KT", :product_type_version=>"1.5.0"},
          :product_identification=>
           {:product_vendor_id=>"INGHC",
            :product_code=>"ORGA6100",
            :product_version=>{:local=>{:hw_version=>"1.2.0", :fw_version=>"3.8.2"}}},
          :product_miscellaneous=>{:product_vendor_name=>nil, :product_name=>nil}},
        :ct_id=>"CT_ID_0176",
        :workplace_ids=>{:workplace_id=>["Konnektor", "GUSbox03"]},
        :name=>"ORGA6100-0241000000B692",
        :mac_address=>"00-0D-F8-0C-86-52",
        :ip_address=>{:ipv4_address=>"10.200.149.235"},
        :slots=>"4",
        :is_physical=>true,
        :connected=>true}
    end

    subject { Cocard::CardTerminal.new(card_terminal_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::CardTerminal.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty card terminal" do
      it "returns nil" do
        expect { Cocard::CardTerminal.new(nil) }.not_to raise_error
      end
    end
   
    describe "with real card terminal" do
      it { expect(subject.product_information).to be_kind_of Cocard::ProductInformation }
      it { expect(subject.ct_id).to eq("CT_ID_0176")}
      it { expect(subject.workplace_ids).to include(workplace_id: ["Konnektor", "GUSbox03"]) }
      it { expect(subject.workplaces).to contain_exactly("Konnektor", "GUSbox03")}
      it { expect(subject.name).to eq("ORGA6100-0241000000B692")}
      it { expect(subject.mac).to eq("00-0D-F8-0C-86-52")}
      it { expect(subject.ip_address).to include(ipv4_address: "10.200.149.235")}
      it { expect(subject.current_ip).to eq("10.200.149.235")}
      it { expect(subject.slots).to eq(4)}
      it { expect(subject.is_physical).to be_truthy }
      it { expect(subject.connected).to be_truthy }
    end

    describe "Cocard::CardTerminal::ATTRIBUTES" do
      it { expect(Cocard::CardTerminal::ATTRIBUTES).to contain_exactly(:properties, :name, :ct_id, :mac, :current_ip, :slots, :connected ) }
    end
  end
end
