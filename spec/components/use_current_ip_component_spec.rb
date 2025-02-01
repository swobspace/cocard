# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCurrentIpComponent, type: :component do
  include Rails.application.routes.url_helpers
  let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "without mismatch" do
    it "shows no button at all" do
      render_inline(described_class.new(item: card_terminal))
      expect(page).not_to have_css('form')
    end
  end

  describe "with ip mismatch" do
    it "shows update button" do
      params = {card_terminal: {ip: '1.2.3.4'}}
      allow(card_terminal).to receive(:current_ip).and_return("1.2.3.4")
      render_inline(described_class.new(item: card_terminal))
      expect(page).to have_css(%Q[form[action="#{card_terminal_path(card_terminal, params)}"]])
    end
  end
end
