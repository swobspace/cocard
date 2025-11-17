# frozen_string_literal: true

require "rails_helper"

RSpec.describe TIClient::RemotePinPlusStateComponent, type: :component do
  let(:card) { RISE::TIClient::RemotePinPlus::Card.new({}) }

  describe "with state = ACTIVE" do
    it "shows ACTIVE badge" do
      expect(card).to receive(:state).at_least(:once).and_return("ACTIVE")
      render_inline(described_class.new(card: card))
      expect(page).to have_css('span[class="badge text-bg-success"]')
    end
  end

  describe "with state = PENDING" do
    it "shows PENDING badge" do
      expect(card).to receive(:state).at_least(:once).and_return("PENDING")
      render_inline(described_class.new(card: card))
      expect(page).to have_css('span[class="badge text-bg-info"]')
    end
  end

  describe "with state = ERROR" do
    it "shows ERROR badge" do
      expect(card).to receive(:state).at_least(:once).and_return("ERROR")
      render_inline(described_class.new(card: card))
      expect(page).to have_css('span[class="badge text-bg-alert"]')
    end
  end

end
