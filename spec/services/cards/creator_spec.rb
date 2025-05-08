# frozen_string_literal: true

require 'rails_helper'
module Cards
  RSpec.describe Creator do
    let(:ctx) { FactoryBot.create(:context) }
    let!(:opsta) { FactoryBot.create(:operational_state, operational: true) }
    # fixtures :operational_states
    let(:connector) { FactoryBot.create(:connector) }
    let!(:ct) do
      FactoryBot.create(:card_terminal, :with_mac,
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
      it 'creates a new card an a new card slot' do
        expect do
          subject.save
        end.to change(Card, :count).by(1)
        expect(subject.card).to be_kind_of(Card)
        cts = subject.card.card_terminal_slot
        expect(cts).to be_kind_of(CardTerminalSlot)
        expect(cts.slotid).to eq(1)
        expect(cts.card_terminal_id).to eq(ct.id)
      end

      context 'new card' do
        let(:card) { subject.save; subject.card }

        it { card.reload; expect(card.card_terminal).to eq(ct) }
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
        it { expect(card.condition_message).to match(/Kein Context konfiguriert/) }
        it { expect(card.condition).to eq(Cocard::States::NOTHING) }

      end

      it { expect(subject.save).to be_truthy }

      describe 'with an existing card' do
        let!(:cts) do
          FactoryBot.create(:card_terminal_slot, card_terminal_id: ct.id, slotid: 1)
        end
        let!(:card) do
          FactoryBot.create(:card, 
            iccsn: '80276002711000000000',
            certificate: 'some string',
            card_terminal_slot:  cts
          )
        end

        before(:each) do 
          card.contexts << ctx; card.reload
        end

        it 'does not create a card' do
          expect {
            subject.save
          }.to change(Card, :count).by(0)
          expect(subject.card).to be_kind_of(Card)
          expect(subject.card).to eq(card)
        end

        it 'does not create a new slot' do
          expect {
            subject.save
          }.to change(CardTerminalSlot, :count).by(0)
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
          it { expect(card.card_terminal_slot).to eq(cts) }
          it { expect(card.insert_time.floor).to eq(ts.floor) }
          it { expect(card.card_holder_name).to eq("Doctor Who's Universe") }
          it { expect(card.expiration_date).to eq(1.year.after(Date.current)) }
          it { expect(card.operational_state.operational).to be_truthy }
          it { expect(card.condition).to eq(Cocard::States::CRITICAL) }
        end
      end

      context 'with a different card in slot' do
        let!(:slot) do
          FactoryBot.create(:card_terminal_slot,
            card_terminal: ct,
            slotid: 1,
          )
        end
        let!(:card) do
          FactoryBot.create(:card, 
            iccsn: '80276002711000009999',
            certificate: 'some string',
            card_terminal_slot: slot
          )
        end

        before(:each) do
          card.contexts << ctx 
          card.update_column(:condition, 1)
          card.reload
        end

        it 'assigns new card to slot' do
          expect(card.condition).to eq(Cocard::States::WARNING)
          subject.save
          slot.reload
          card.reload
          expect(slot.card).to eq(subject.card)
          expect(card.condition).to eq(Cocard::States::NOTHING)
        end
      end

      context 'with non existing card terminal' do
        before(:each) do
          expect(cc).to receive(:ct_id).and_return('NOTEXISTENT')
        end

        it "does not raise an error" do
          expect {
            subject.save
          }.not_to raise_error
        end

        it "doesn't create a new card" do
          expect {
            subject.save
          }.not_to change(Card, :count)
        end
      end
    end

    describe "same card, changing slots" do
      let!(:card) do
        FactoryBot.create(:card, 
          iccsn: '80276002711000000000',
          certificate: 'some string'
        )
      end
      let!(:slot) do
        FactoryBot.create(:card_terminal_slot,
          card_terminal: ct,
          slotid: 1,
          card: card
        )
      end

      context "with same card in other slot" do
        it "changes slotid" do
          expect(cc).to receive(:slotid).and_return(3)
          expect(card.slotid).to eq(1)
          expect {
            subject.save
          }.to change(CardTerminalSlot, :count).by(1)
          slot.reload
          card.reload
          expect(card.card_terminal_slot).not_to eq(slot)
          expect(card.slotid).to eq(3)
          expect(slot.card).to be_nil
        end
      end

      context "with same card in other ct" do
        let!(:ct2) do
          FactoryBot.create(:card_terminal, :with_mac,
            connector_id: connector.id,
            ct_id: 'CT_ID_0177'
          )
        end
        it "changes card terminal" do
          expect(cc).to receive(:ct_id).and_return('CT_ID_0177')
          expect(card.card_terminal.ct_id).to eq('CT_ID_0176')
          expect {
            subject.save
          }.to change(CardTerminalSlot, :count).by(1)
          slot.reload
          card.reload
          expect(card.card_terminal.ct_id).to eq('CT_ID_0177')
          expect(card.slotid).to eq(1)
          expect(slot.card).to be_nil
        end
      end
    end

    describe "with card_type 'EGK'" do
      before(:each) do
        card_hash.merge!({card_type: 'EGK'})
      end
      it { expect(subject.save).to be_falsey }
    end
  end
end
