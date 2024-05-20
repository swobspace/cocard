# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::GetCardButtonComponent, type: :component do
  let(:card) do
    FactoryBot.create(:card,
      card_type: 'SMC-B',
    )
  end

  describe "with but force == true " do
    it "shows green ok utf char" do
      render_inline(described_class.new(card: card, force: true))
      expect(page).to have_css('button[class="btn btn-warning me-1"]', text: 'Karte aktualisieren')
    end
  end

  describe "with connector -> manual_update == true " do
    it "shows green ok utf char" do
      expect(card).to receive_message_chain(:card_terminal, :connector, :manual_update).and_return(true)
      render_inline(described_class.new(card: card))
      expect(page).to have_css('button[class="btn btn-warning me-1"]', text: 'Karte aktualisieren')
    end
  end

  describe "with connector -> manual_update == false" do
    it "shows green ok utf char" do
      expect(card).to receive_message_chain(:card_terminal, :connector, :manual_update).and_return(false)
      render_inline(described_class.new(card: card))
      expect(page).not_to have_content("Karte aktualisieren")
    end
  end

  describe "with connector -> manual_update " do
    it "shows green ok utf char" do
      expect(card).to receive_message_chain(:card_terminal, :connector, :manual_update).and_return(true)
      render_inline(described_class.new(card: card))
      expect(page).to have_css('button[class="btn btn-warning me-1"]', text: 'Karte aktualisieren')
    end
  end

end
