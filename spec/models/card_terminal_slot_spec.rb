require 'rails_helper'

RSpec.describe CardTerminalSlot, type: :model do
  let!(:location) { FactoryBot.create(:location, lid: 'ACX') }
  let(:ct) do
    FactoryBot.create(:card_terminal, :with_mac, 
      location: location,
      ip: '127.6.19.23'
    )
  end

  it { is_expected.to belong_to(:card_terminal) }
  it { is_expected.to have_one(:card).optional }

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_terminal_slot)
    g = FactoryBot.create(:card_terminal_slot)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:slotid).scoped_to(:card_terminal_id)
  end

  describe "with deleted card" do
    let!(:slot) { FactoryBot.create(:card_terminal_slot, slotid: 4, card_terminal: ct ) }
    let!(:card) { FactoryBot.create(:card, card_terminal_slot_id: slot.id) }

    before(:each) do
      card.update_column(:deleted_at, Time.current)
      slot.reload
    end

    it "slot.card shows card" do
      expect(slot.card).to eq(card)
    end
  end


end
