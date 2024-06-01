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

end
