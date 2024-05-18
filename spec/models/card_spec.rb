require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:connector) { FactoryBot.create(:connector) }
  let(:ct) { FactoryBot.create(:card_terminal, connector: connector) }
  let(:ctx) { FactoryBot.create(:context) }
  let(:card) do
    FactoryBot.create(:card, 
      card_holder_name: "Doctor Who's Universe",
      card_terminal: ct,
      context: ctx,
      expiration_date: 2.years.after(Date.current),
      pin_status: 'VERIFIED',
      updated_at: Time.current
    )
  end

  it { is_expected.to belong_to(:card_terminal).optional }
  it { is_expected.to belong_to(:context).optional }
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

  describe "#update_condition" do
    # it { expect(card.condition).to eq(Cocard::States::NOTHING) }

    describe "without card_terminal" do
      it "-> NOTHING" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:card_terminal).and_return(nil)
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::NOTHING)
      end
    end

    describe "SMC-B without Context" do
      it "-> NOTHING" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:context).and_return(nil)
        expect(card).to receive(:card_type).and_return('SMC-B')
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::NOTHING)
      end
    end

    describe "with expired certificate" do
      it "-> CRITICAL" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:expiration_date).at_least(:once).and_return(1.day.before(Date.current))
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "SMC-B PIN not verified" do
      it "-> CRITICAL" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:pin_status).and_return('BLOCKED')
        expect(card).to receive(:card_type).at_least(:once).and_return('SMC-B')
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::CRITICAL)
      end
    end

    describe "with certificate expiration <= 3 month" do
      it "-> WARNING" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:expiration_date).at_least(:once).and_return(1.month.after(Date.current))
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
    end

    describe "with updated at 1 hour ago" do
      it "-> UNKNOWN" do
        card.update(condition: Cocard::States::OK)
        card.reload
        expect(card).to receive(:updated_at).at_least(:once).and_return(1.hour.before(Time.current))
        expect {
          card.update_condition
        }.to change(card, :condition).to(Cocard::States::UNKNOWN)
      end
    end
  end

  describe "#condition_message" do
    describe "with condition = CRITICAL" do
      before(:each) do
        expect(ct).to receive(:condition).and_return(Cocard::States::CRITICAL)
      end
      it { expect(ct.condition_message).to match(/CRITICAL/) }
    end
    describe "with condition = UNKNOWN" do
      before(:each) do
        expect(ct).to receive(:condition).and_return(Cocard::States::UNKNOWN)
      end
      it { expect(ct.condition_message).to match(/UNKNOWN/) }
    end
    describe "with condition = WARNING" do
      before(:each) do
        expect(ct).to receive(:condition).and_return(Cocard::States::WARNING)
      end
      it { expect(ct.condition_message).to match(/WARNING/) }
    end
    describe "with condition = OK" do
      before(:each) do
        expect(ct).to receive(:condition).and_return(Cocard::States::OK)
      end
      it { expect(ct.condition_message).to match(/OK/) }
    end
    describe "with condition = NOTHING" do
      before(:each) do
        expect(ct).to receive(:condition).and_return(Cocard::States::NOTHING)
      end
      it { expect(ct.condition_message).to match(/UNUSED/) }
    end
  end
end
