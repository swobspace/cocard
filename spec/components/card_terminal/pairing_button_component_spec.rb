# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardTerminal::PairingButtonComponent, type: :component do

  describe "with supported terminal" do
    let(:ct) do
      FactoryBot.create(:card_terminal, :with_mac,
        identification: 'INGHC-ORGA6100',
        firmware_version: '3.9.2',
      )
    end

    describe "not connected" do
      it "shows warning button" do
        render_inline(described_class.new(card_terminal: ct))
        expect(page).to have_css('form[class="button_to"]')
        expect(page).to have_css('button[class="btn btn-warning me-1"]')
      end
    end

    describe "connected" do
      it "shows danger button" do
        ct.update_column(:connected, true)
        ct.reload
        render_inline(described_class.new(card_terminal: ct))
        expect(page).to have_css('form[class="button_to"]')
        expect(page).to have_css('button[class="btn btn-danger me-1"]')
      end
    end
  end

  describe "with older firmware" do
    let(:ct) do
      FactoryBot.create(:card_terminal, :with_mac,
        identification: 'INGHC-ORGA6100',
        firmware_version: '3.8.2',
      )
    end

    it "does not show button" do
      render_inline(described_class.new(card_terminal: ct))
      expect(page).not_to have_css('form[class="button_to"]')
      expect(rendered_content).to be_empty
    end
  end

end
