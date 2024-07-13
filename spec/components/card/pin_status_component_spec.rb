# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::PinStatusComponent, type: :component do
  let(:card) { FactoryBot.create(:card) }
  let(:cctx) { FactoryBot.create(:card_context, card: card) }

  describe "with pin status VERIFIED " do
    it "shows green ok utf char" do
      expect(cctx).to receive(:pin_status).and_return("VERIFIED")
      render_inline(described_class.new(card: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::OK))
    end
  end

  describe "with pin status BLOCKED " do
    it "shows green ok utf char" do
      expect(cctx).to receive(:pin_status).at_least(:once).and_return("BLOCKED")
      render_inline(described_class.new(card: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::CRITICAL))
    end
  end

end
