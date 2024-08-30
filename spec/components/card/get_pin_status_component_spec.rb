# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::GetPinStatusComponent, type: :component do
  let(:card) do
    FactoryBot.create(:card,
      card_type: 'SMC-B',
    )
  end
  let(:context) { FactoryBot.create(:context) }

  describe "with pin status OK" do
    it "shows green pin symbol" do
      expect(card).to receive(:pin_status).with(any_args).and_return(Cocard::States::OK) 
      render_inline(described_class.new(card: card, context: context))
      expect(page).to have_css('button[class="btn btn-warning me-1 text-success"]')
    end
  end

  describe "with pin status CRITICAL" do
    it "shows red pin symbol" do
      expect(card).to receive(:pin_status).with(any_args).and_return(Cocard::States::CRITICAL) 
      render_inline(described_class.new(card: card, context: context))
      expect(page).to have_css('button[class="btn btn-warning me-1 text-danger"]')
    end
  end

end
