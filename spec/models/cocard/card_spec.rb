require 'rails_helper'

module Cocard
  RSpec.describe Card, type: :model do
    let!(:ts) { 1.day.before(Time.current) }
    let(:card_hash) do
       {:card_handle=>"ee676b27-5b40-4a40-9c65-979cc3113a1e",
        :card_type=>"SMC-B",
        :card_version=>
         {:cos_version=>{:major=>"4", :minor=>"5", :revision=>"0"},
          :object_system_version=>{:major=>"4", :minor=>"8", :revision=>"0"},
          :atr_version=>{:major=>"2", :minor=>"0", :revision=>"0"},
          :gdo_version=>{:major=>"1", :minor=>"0", :revision=>"0"}},
        :iccsn=>"80276002711000000000",
        :ct_id=>"CT_ID_0176",
        :slot_id=>"1",
        :insert_time=>ts,
        :card_holder_name=>"Doctor Who's Universe",
        :certificate_expiration_date=>1.year.after(Date.current)}
    end

    subject { Cocard::Card.new(card_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::Card.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty card" do
      it "returns nil" do
        expect { Cocard::Card.new(nil) }.not_to raise_error
      end
    end
   
    describe "with real card" do
      it { expect(subject.properties).to eq(card_hash) }
      it { expect(subject.card_handle).to eq("ee676b27-5b40-4a40-9c65-979cc3113a1e")}
      it { expect(subject.card_type).to eq("SMC-B")}
      it { expect(subject.iccsn).to eq("80276002711000000000")}
      it { expect(subject.ct_id).to eq("CT_ID_0176")}
      it { expect(subject.slotid).to eq(1)}
      it { expect(subject.insert_time).to eq(ts)}
      it { expect(subject.card_holder_name).to eq("Doctor Who's Universe")}
      it { expect(subject.expiration_date).to eq(1.year.after(Date.current))}
      it { expect(subject.card_version).to be_kind_of(Cocard::Cards::Version) }
      it { expect(subject.object_system_version).to eq("4.8.0") }
    end

    describe "Cocard::Card::ATTRIBUTES" do
      it { expect(Cocard::Card::ATTRIBUTES).to contain_exactly(:properties, :card_handle, :card_type, :iccsn, :insert_time, :card_holder_name, :expiration_date ) }
    end
  end
end
