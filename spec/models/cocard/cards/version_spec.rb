require 'rails_helper'

module Cocard::Cards
  RSpec.describe Version, type: :model do
    let(:card_version) do
      { :cos_version=>{:major=>"4", :minor=>"5", :revision=>"0"},
        :object_system_version=>{:major=>"4", :minor=>"8", :revision=>"0"},
        :atr_version=>{:major=>"2", :minor=>"0", :revision=>"0"},
        :gdo_version=>{:major=>"1", :minor=>"0", :revision=>"0"}}
    end

    subject { Cocard::Cards::Version.new(card_version) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::Cards::Version.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty version" do
      it "returns nil" do
        expect { Cocard::Cards::Version.new(nil) }.not_to raise_error
      end
    end
   
    describe "with real version" do
      it { expect(subject.card_version).to eq(card_version) }
      it { expect(subject.cos_version).to eq("4.5.0") }
      it { expect(subject.object_system_version).to eq("4.8.0") }
      it { expect(subject.atr_version).to eq("2.0.0") }
      it { expect(subject.gdo_version).to eq("1.0.0") }
    end

    describe "Cocard::Cards::ATTRIBUTES" do
      it { expect(Cocard::Cards::Version::ATTRIBUTES).to contain_exactly(:cos_version, :object_system_version, :atr_version, :gdo_version) }
    end
  end
end
