# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardTerminal::ConnectedComponent, type: :component do
  let(:ct) { FactoryBot.create(:card_terminal) }

  describe "with status connected " do
    it "shows green ok utf char" do
      expect(ct).to receive(:connected).and_return(true)
      render_inline(described_class.new(card_terminal: ct))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::OK))
    end
  end

  describe "with status not connected " do
    it "shows red cross utf char" do
      expect(ct).to receive(:connected).and_return(false)
      render_inline(described_class.new(card_terminal: ct))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::CRITICAL))
    end
  end

end
