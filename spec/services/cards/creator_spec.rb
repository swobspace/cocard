# frozen_string_literal: true

require 'rails_helper'
module Cards
  RSpec.describe Creator do
    let(:ctx) { FactoryBot.create(:context) }
    let!(:opsta) { FactoryBot.create(:operational_state, operational: true) }
    # fixtures :operational_states
    let(:connector) { FactoryBot.create(:connector) }
    let!(:ct) do
      FactoryBot.create(:card_terminal, 
        connector_id: connector.id,
        ct_id: 'CT_ID_0176'
      )
    end
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

    let(:cc) { Cocard::Card.new(card_hash) }

    subject { Cards::Creator.new(connector: connector, cc: cc, context: ctx) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(Cards::Creator) }
      it { expect(subject.respond_to?(:save)).to be_truthy }
    end

    describe '#new' do
      context 'without :cc' do
        it 'raises a KeyError' do
          expect do
            Creator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#save' do
      context 'new card' do
        let(:card) { subject.save; subject.card }
        it 'create a new card' do
          expect do
            subject.save
          end.to change(Card, :count).by(1)
          expect(subject.card).to be_kind_of(Card)
        end

        it { expect(card.card_terminal).to eq(ct) }
        it { expect(card.name).to eq("") }
        it { expect(card.description.to_plain_text).to eq("") }
        it { expect(card.card_handle).to eq("ee676b27-5b40-4a40-9c65-979cc3113a1e") }
        it { expect(card.card_type).to eq("SMC-B") }
        it { expect(card.iccsn).to eq("80276002711000000000") }
        it { expect(card.slotid).to eq(1) }
        it { expect(card.insert_time.floor).to eq(ts.floor) }
        it { expect(card.card_holder_name).to eq("Doctor Who's Universe") }
        it { expect(card.expiration_date).to eq(1.year.after(Date.current)) }
        it { expect(card.operational_state.operational).to be_truthy }
        it { expect(card.condition).to eq(Cocard::States::CRITICAL) }

      end

      it { expect(subject.save).to be_truthy }

      context 'with an existing card' do
        let!(:card) do
          FactoryBot.create(:card, 
            iccsn: '80276002711000000000',
            context: ctx
          )
        end
        before(:each) { card.reload }
        it 'does not create a card' do
          expect {
            subject.save
          }.to change(Card, :count).by(0)
          expect(subject.card).to be_kind_of(Card)
          expect(subject.card).to eq(card)
        end

        it { expect(subject.save).to be_truthy }

        context 'update attributes' do
          before(:each) do
            subject.save
            card.reload
          end
          it { expect(card.card_terminal).to eq(ct) }
          it { expect(card.name).to eq("") }
          it { expect(card.description.to_plain_text).to eq("") }
          it { expect(card.card_handle).to eq("ee676b27-5b40-4a40-9c65-979cc3113a1e") }
          it { expect(card.card_type).to eq("SMC-B") }
          it { expect(card.iccsn).to eq("80276002711000000000") }
          it { expect(card.slotid).to eq(1) }
          it { expect(card.insert_time.floor).to eq(ts.floor) }
          it { expect(card.card_holder_name).to eq("Doctor Who's Universe") }
          it { expect(card.expiration_date).to eq(1.year.after(Date.current)) }
          it { expect(card.operational_state.operational).to be_truthy }
          it { expect(card.condition).to eq(Cocard::States::CRITICAL) }
        end
      end
    end
  end
end
