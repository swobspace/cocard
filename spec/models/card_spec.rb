require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:location) { FactoryBot.create(:location) }
  let(:connector) { FactoryBot.create(:connector) }
  let(:ct) do
    FactoryBot.create(:card_terminal, :with_mac, 
      connector: connector,
      location: location,
      ip: '127.6.19.23'
    )
  end
  let(:context) { FactoryBot.create(:context) }
  let(:opsta) { FactoryBot.create(:operational_state, operational: true) }
  let(:card) do
    FactoryBot.create(:card, 
      card_holder_name: "Doctor Who's Universe",
      card_terminal: ct,
      expiration_date: 2.years.after(Date.current),
      updated_at: Time.current,
      operational_state: opsta,
      certificate: "some string"
    )
  end
  it { is_expected.to have_many(:logs) }
  it { is_expected.to belong_to(:acknowledge).optional }
  it { is_expected.to have_many(:notes).dependent(:destroy) }
  it { is_expected.to have_many(:plain_notes).dependent(:destroy) }
  it { is_expected.to have_many(:acknowledges).dependent(:destroy) }
  it { is_expected.to belong_to(:card_terminal_slot).optional }
  it { is_expected.to have_one(:card_terminal).through(:card_terminal_slot) }
  it { is_expected.to have_many(:tags).through(:taggings) }

  it { is_expected.to have_many(:card_contexts).dependent(:destroy) }
  it { is_expected.to have_many(:contexts).through(:card_contexts) }
  it { is_expected.to belong_to(:location).optional }
  it { is_expected.to belong_to(:operational_state).optional }
  it { is_expected.to validate_presence_of(:iccsn) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:card)
    g = FactoryBot.create(:card)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:iccsn).case_insensitive
  end

  describe "#to_s" do
    it { expect(card.to_s).to match("#{card.iccsn} - Doctor Who's Universe") }
  end

  describe "#save" do
    before(:each) do
      card.update_column(:location_id, nil)
      card.reload
      expect(card.location_id).to eq(nil)
    end

    it "updates location with SMC-KT" do
      expect(card).to receive(:card_type).at_least(:once).and_return('SMC-KT')
      expect {
        card.save
      }.to change(card, :location_id).to(location.id)
    end

    it "updates location with SMC-B" do
      expect(card).to receive(:card_type).at_least(:once).and_return('SMC-B')
      expect {
        card.save
      }.to change(card, :location_id).to(location.id)
    end

    it "updates location with HBA" do
      expect(card).to receive(:card_type).at_least(:once).and_return('HBA')
      expect {
        card.save
      }.not_to change(card, :location_id)
    end
  end

  describe "#update_condition" do
    before(:each) do
      card.contexts << context
    end

    # it { expect(card.condition).to eq(Cocard::States::NOTHING) }

    describe "wit operational_state == not operational" do
      it "-> NOTHING" do
        card.update(condition: Cocard::States::OK)
        card.reload
        allow(card).to receive_message_chain(:operational_state, :operational).and_return(nil)
        expect(card).to receive_message_chain(:operational_state, :name).and_return(nil)
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::NOTHING)
      end
    end

    describe "without card_terminal" do
      it "-> NOTHING" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive_message_chain(:card_terminal_slot, :card_terminal_id).and_return(nil)
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::NOTHING)
      end
    end

    describe "SMC-B without Context" do
      it "-> NOTHING" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:contexts).and_return([])
        expect(card).to receive(:card_type).at_least(:once).and_return('SMC-B')
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::NOTHING)
      end
    end

    describe "with expired certificate" do
      it "-> CRITICAL" do
        card.update_column(:condition, Cocard::States::OK)
        card.reload
        expect(card).to receive(:expiration_date).at_least(:once).and_return(1.day.before(Date.current))
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "SMC-B PIN not verified" do
      it "-> CRITICAL" do
        card.update_column(:condition, Cocard::States::OK)
        card.reload
        expect(card).to receive(:pin_status).and_return(Cocard::States::CRITICAL)
        expect(card).to receive(:card_type).at_least(:once).and_return('SMC-B')
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "with certificate expiration <= 3 month" do
      it "-> WARNING" do
        expect(card).to receive(:expiration_date).at_least(:once).and_return(1.month.after(Date.current))
        card.update_column(:condition, Cocard::States::OK)
        card.reload
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::WARNING)
      end
    end

    describe "SMC-B certificate not read" do
      it "-> UNKNOWN" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:certificate).and_return('')
        expect(card).to receive(:card_type).at_least(:once).and_return('SMC-B')
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::UNKNOWN)
      end

      describe "changing to OK" do
        let(:ack) do 
          FactoryBot.create(:note, notable: card, 
            type: Note.types[:acknowledge]
          )
        end
 
        it "auto-closes ack" do
          card.update_columns(acknowledge_id: ack.id, condition: Cocard::States::WARNING)
          card.reload
          expect(card.acknowledge).to eq(ack)
          expect(card.condition).to eq(Cocard::States::WARNING)
          expect {
            card.update_condition
          }.to change(card, :condition).to(Cocard::States::OK)
          card.reload
          expect(card.acknowledge).to be_nil
          ack.reload
          expect(ack.valid_until).to be >= 1.second.before(Time.current)
          expect(ack.valid_until).to be <= 1.second.after(Time.current)
        end
      end
    end

    describe "with updated at 1 hour ago" do
      it "-> UNKNOWN" do
        card.update(condition: Cocard::States::OK)
        card.reload
        allow(card).to receive(:updated_at).at_least(:once).and_return(1.hour.before(Time.current))
        expect {
          card.update_condition
        }.not_to change(card, :condition)
      end
    end
  end


  describe "#pin_status" do
    let!(:cctx1) { FactoryBot.create(:card_context, card: card) }
    let!(:cctx2) { FactoryBot.create(:card_context, card: card) }

    describe "with 2x pin_status = nil" do
      before(:each) do
        card.reload
      end
      it { expect(card.pin_status).to eq(Cocard::States::CRITICAL) }
    end

    describe "with 2x pin_status = 'VERIFIED'" do
      before(:each) do
        cctx1.update(pin_status: 'VERIFIED'); cctx1.reload
        cctx2.update(pin_status: 'VERIFIED'); cctx2.reload
      end
      # it { puts card.card_contexts.pluck(:pin_status) }
      it { expect(card.pin_status).to eq(Cocard::States::OK) }
    end

    describe "with contexts.empty?" do
      let(:card2) { FactoryBot.create(:card) }
      # it { puts card2.card_contexts }
      it { expect(card2.pin_status).to eq(Cocard::States::WARNING) }
    end

    describe "with single context" do
      before(:each) do
        cctx1.update(pin_status: 'VERIFIED'); cctx1.reload
      end

      it { expect(card.pin_status(cctx1.context_id)).to eq(Cocard::States::OK) }
      it { expect(card.pin_status(cctx2.context_id)).to eq(Cocard::States::CRITICAL) }
    
    end
  end

  describe "with notes" do
    let!(:note) { FactoryBot.create(:note, notable: card, type: Note.types[:plain]) }
    let!(:ack) { FactoryBot.create(:note, notable: card, type: Note.types[:acknowledge]) }
    let!(:oldnote) do
      FactoryBot.create(:note,
        notable: card,
        type: Note.types[:plain],
        valid_until: Date.yesterday
      )
    end
    let!(:oldack) do
      FactoryBot.create(:note,
        notable: card,
        type: Note.types[:acknowledge],
        valid_until: Date.yesterday
      )
    end

    it { expect(card.acknowledges).to contain_exactly(ack, oldack) }
    it { expect(card.current_acknowledge).to eq(ack) }
    it { expect(card.acknowledges.active).to contain_exactly(ack) }
    it { expect(card.acknowledges.count).to eq(2) }
    it { expect(card.current_note).to eq(note) }
    it { expect(card.notes.active).to contain_exactly(note, ack) }
    it { expect(card.notes.count).to eq(4) }
    it { expect(card.plain_notes).to contain_exactly(note, oldnote) }
    it { expect(card.plain_notes.active).to contain_exactly(note) }
    it { expect(card.plain_notes.count).to eq(2) }


    it "sets acknowledge_id" do
      expect {
        card.save
      }.to change(card, :acknowledge_id)
    end

    describe "#close_acknowledge" do
      before(:each) do
        card.update_column(:acknowledge_id, ack.id)
        card.reload
      end

      it "terminates current ack" do
        expect(card.acknowledge).to eq(ack)
        expect {
          card.close_acknowledge
        }.to change(card, :acknowledge_id).to(nil)
      end

      it "deletes acknowledge_id" do
        expect(card.acknowledge).to eq(ack)
        ack.update(valid_until: 1.minute.before(Time.current))
        card.save
        expect(card.acknowledge_id).to be(nil)
      end

    end
  end

  describe "#destroy" do
    let(:card) { FactoryBot.create(:card, card_type: 'SMC-KT') }
    let!(:slot) { FactoryBot.create(:card_terminal_slot, slotid: 4, card: card) }

    it "doesn't destroy card_terminal_slot" do
      expect(slot.card).to eq(card)
      expect {
        card.destroy
      }.to change(CardTerminalSlot, :count).by(0)
    end
  end

  describe "Taggable" do
    before(:each) do
      card.tag_list = %w[ Eins Zwei ]
      card.reload
    end
  
    it { expect(card.tag_list).to contain_exactly('Eins', 'Zwei') }
  
    it "doesn't delete tags on save" do
      expect {
        card.update(last_check: Time.current)
      }.not_to change(card, :tag_list)
    end
  end

end
