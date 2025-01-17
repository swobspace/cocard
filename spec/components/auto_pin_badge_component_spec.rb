# frozen_string_literal: true

require "rails_helper"

RSpec.describe AutoPinBadgeComponent, type: :component do
  let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "with pin_mode == off" do
    it "shows grey badge" do
      allow(card_terminal).to receive(:pin_mode).and_return("off")
      render_inline(described_class.new(card_terminal: card_terminal))
      expect(page).to have_css('span[class="badge text-bg-secondary"]')
    end
  end

  describe "with pin_mode == On demand" do
    it "shows info badge" do
      allow(card_terminal).to receive(:pin_mode).and_return("on_demand")
      render_inline(described_class.new(card_terminal: card_terminal))
      expect(page).to have_css('span[class="badge text-bg-info"]')
    end
  end

  describe "with pin_mode == Automatisch" do
    it "shows ok badge" do
      allow(card_terminal).to receive(:pin_mode).and_return("auto")
      render_inline(described_class.new(card_terminal: card_terminal))
      expect(page).to have_css('span[class="badge text-bg-success"]')
    end
  end
end
