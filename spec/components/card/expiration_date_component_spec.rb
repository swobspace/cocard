# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::ExpirationDateComponent, type: :component do
 let(:card) { FactoryBot.create(:card) }

  describe "with card valid > 3 month" do
    it "shows green ok utf char" do
      expect(card).to receive(:expiration_date).at_least(:once).and_return(2.years.after(Date.current))
      render_inline(described_class.new(card: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::OK))
    end
  end

  describe "with card valid < 3 month" do
    it "shows yellow warning utf char" do
      expect(card).to receive(:expiration_date).at_least(:once).and_return(1.month.after(Date.current))
      render_inline(described_class.new(card: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::WARNING))
    end
  end

  describe "with expired card" do
    it "shows red cross  utf char" do
      expect(card).to receive(:expiration_date).at_least(:once).and_return(1.day.before(Date.current))
      render_inline(described_class.new(card: card))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::CRITICAL))
    end
  end
end
