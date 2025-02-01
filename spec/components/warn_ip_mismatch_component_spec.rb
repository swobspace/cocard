# frozen_string_literal: true

require "rails_helper"

RSpec.describe WarnIpMismatchComponent, type: :component do
  let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "without mismatch" do
    it "shows no badge at all" do
      render_inline(described_class.new(item: card_terminal))
      expect(page).not_to have_css('span')
    end
  end

  describe "with ip mismatch" do
    it "shows warning badge" do
      allow(card_terminal).to receive(:current_ip).and_return("1.2.3.4")
      render_inline(described_class.new(item: card_terminal))
      expect(page).to have_css('span[class="badge text-bg-info opacity-75"]')
    end
  end
end
