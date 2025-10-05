# frozen_string_literal: true

require "rails_helper"

RSpec.describe WarnIpMismatchComponent, type: :component do
  let(:conn)          { FactoryBot.create(:connector) }
  let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "without mismatch" do
    it "shows no badge at all" do
      allow(card_terminal).to receive(:ip).and_return("2.3.4.5")
      allow(card_terminal).to receive(:current_ip).and_return("nil")
      render_inline(described_class.new(item: card_terminal))
      puts rendered_content
      expect(page).not_to have_css('span')
    end
  end

  describe "with ip mismatch" do
    it "shows warning badge" do
      allow(card_terminal).to receive(:ip).and_return("2.3.4.5")
      allow(card_terminal).to receive(:current_ip).and_return("1.2.3.4")
      allow(card_terminal).to receive(:connector).and_return(conn)
      render_inline(described_class.new(item: card_terminal))
      # puts rendered_content
      expect(page).to have_css('span[class="badge text-bg-info opacity-75"]')
    end
  end
end
