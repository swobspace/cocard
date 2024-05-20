# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::GetCertificateButtonComponent, type: :component do
  let(:card) do
    FactoryBot.create(:card,
      card_type: 'SMC-B',
    )
  end

  describe "with force == true " do
    it "shows green ok utf char" do
      render_inline(described_class.new(card: card, force: true))
      expect(page).to have_css('button[class="btn btn-warning me-1"]', text: 'Zertifikat lesen')
    end
  end

  describe "with manual_update == true  certificate.blank?" do
    it "shows green ok utf char" do
      expect(card).to receive_message_chain(:card_terminal, :connector, :manual_update).and_return(true)
      expect(card).to receive(:certificate).and_return(nil)
      render_inline(described_class.new(card: card))
      expect(page).to have_css('button[class="btn btn-warning me-1"]', text: 'Zertifikat lesen')
    end
  end

  describe "with manual_update == true  certificate.present?" do
    it "shows green ok utf char" do
      expect(card).to receive_message_chain(:card_terminal, :connector, :manual_update).and_return(true)
      expect(card).to receive(:certificate).and_return("DDDDDDDDDDDDDDDDDDDDDDd")
      render_inline(described_class.new(card: card))
      expect(page).not_to have_css('button[class="btn btn-warning me-1"]', text: 'Zertifikat lesen')
    end
  end

end
