# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe Creator do
    let(:connector) { FactoryBot.create(:connector) }
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
    let(:cct) { Cocard::CardTerminal.new(card_terminal_hash) }

    subject { CardTerminals::Creator.new(connector: connector, cct: cct) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(CardTerminals::Creator) }
      it { expect(subject.respond_to?(:save)).to be_truthy }
    end

    describe '#new' do
      context 'without :cct' do
        it 'raises a KeyError' do
          expect do
            Creator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#save' do
      context 'new card_terminal' do
        it 'create a new card_terminal' do
          expect do
            subject.save
          end.to change(CardTerminal, :count).by(1)
        end
      end

      context 'with an existing card_terminal' do
        let!(:ct) do
          FactoryBot.create(:card_terminal, mac: '00:0d:f8:0c:86:52')
        end
        it 'does not create a card terminal' do
          expect {
            subject.save
          }.to change(CardTerminal, :count).by(0)
        end

        it { expect(subject.save).to be_truthy }

        context 'update attributes' do
          before(:each) do
            subject.save
            ct.reload
          end
          it { expect(ct.product_information).to be_kind_of Cocard::ProductInformation }
          it { expect(ct.ct_id).to eq("CT_ID_0176")}
          # it { expect(ct.workplaces).to contain_exactly("Konnektor", "GUSbox03")}
          it { expect(ct.name).to eq("ORGA6100-0241000000B692")}
          it { expect(ct.mac).to eq("00:0d:f8:0c:86:52")}
          it { expect(ct.ip).to eq("10.200.149.235")}
          it { expect(ct.slots).to eq(4)}
          # it { expect(ct.is_physical).to be_truthy }
          it { expect(ct.connected).to be_truthy }
        end
      end
    end
  end
end
