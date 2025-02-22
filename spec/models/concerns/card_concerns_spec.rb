require 'rails_helper'

RSpec.describe CardConcerns, type: :model do
  let(:card) do
    FactoryBot.create(:card, 
      name: "My First Card",
      card_holder_name: "Doctor Who's Universe"
    )
  end

  describe "#name_or_cardholder" do
    context "with name" do
      it { expect(card.name_or_cardholder).to eq("My First Card") }
    end

    context "without name" do
      before(:each) do
        expect(card).to receive(:name).and_return("")
      end
      it { expect(card.name_or_cardholder).to eq("Doctor Who's Universe") }
    end
  end


  describe "for PIN verification" do
    let(:connector) { FactoryBot.create(:connector) }
    let(:opstate) { FactoryBot.create(:operational_state, operational: true) }
    let(:ct1) do 
      FactoryBot.create(:card_terminal, :with_mac, 
        connector: connector,
        pin_mode: :on_demand
      )
    end
    let(:ct2) do
      FactoryBot.create(:card_terminal, :with_mac, 
        connector: connector, 
        pin_mode: :auto
      )
    end 

    let(:card1) { FactoryBot.create(:card, operational_state: opstate) }
    let(:card2) { FactoryBot.create(:card, operational_state: opstate) }
    let(:card3) { FactoryBot.create(:card, operational_state: opstate) }

    let!(:slot1) do 
      FactoryBot.create(:card_terminal_slot,
        card_terminal: ct1,
        slotid: 1,
        card: card1
      )
    end

    let!(:slot2) do 
      FactoryBot.create(:card_terminal_slot,
        card_terminal: ct2,
        slotid: 2,
        card: card2
      )
    end

    let!(:slot3) do 
      FactoryBot.create(:card_terminal_slot,
        card_terminal: ct2,
        slotid: 3,
        card: card3
      )
    end

    let!(:cctx1) do 
      FactoryBot.create(:card_context,
        card: card1,
        pin_status: 'VERIFIABLE',
        left_tries: 3
      )
    end
    let!(:cctx2) do 
      FactoryBot.create(:card_context,
        card: card1,
        pin_status: 'VERIFIABLE',
        left_tries: 2
      )
    end
    let!(:cctx3) do 
      FactoryBot.create(:card_context,
        card: card3,
        pin_status: 'VERIFIED',
        left_tries: 3
      )
    end
    let!(:cctx4) do 
      FactoryBot.create(:card_context,
        card: card2,
        pin_status: 'VERIFIABLE',
        left_tries: 3
      )
    end

    it { expect(Card.verifiable).to contain_exactly(card1, card2) }
    it { expect(Card.verifiable_auto).to contain_exactly(card2) }
  end

end
