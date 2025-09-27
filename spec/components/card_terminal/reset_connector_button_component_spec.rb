# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardTerminal::ResetConnectorButtonComponent, type: :component do
  include Rails.application.routes.url_helpers
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "with connector" do
    let(:conn) { FactoryBot.create(:connector) }
    before(:each) do
      ct.update(connector: conn); ct.reload
    end

    describe "#condition == UNKNOWN" do
      it "shows reset button"  do
        expect(ct).to receive(:condition).and_return(Cocard::States::UNKNOWN)
        render_inline(described_class.new(card_terminal: ct))
        expect(page).to have_css('button[class="btn btn-sm btn-warning ms-3"]', text: 'Reset')
        expect(page).to have_css(%Q[form[action="#{card_terminal_path(ct)}"]])
      end
    end

    describe "#condition == OK" do
      it "does not show reset button"  do
        expect(ct).to receive(:condition).and_return(Cocard::States::OK)
        expect(ct).to receive(:last_check).at_least(:once).and_return(Time.current)
        render_inline(described_class.new(card_terminal: ct))
        expect(page).not_to have_css('button[class="btn btn-sm btn-warning ms-3"]', text: 'Reset')
      end
    end
  end

  describe "without connector" do
    it "does not show reset button"  do
      render_inline(described_class.new(card_terminal: ct))
      expect(page).not_to have_css('button[class="btn btn-sm btn-warning ms-3"]', text: 'Reset')
    end
  end
end
