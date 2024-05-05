require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:card) do
    FactoryBot.create(:card, 
      card_holder_name: "Doctor Who's Universe",
    )
  end

  it { is_expected.to belong_to(:card_terminal).optional }

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
end
