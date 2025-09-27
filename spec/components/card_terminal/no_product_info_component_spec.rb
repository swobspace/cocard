# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardTerminal::NoProductInfoComponent, type: :component do
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "with properties available " do
    it "shows no output" do
      expect(ct).to receive(:properties).and_return({some: "stuff"})
      render_inline(described_class.new(card_terminal: ct))
      expect(rendered_content).to eq("")
    end
  end

  describe "without properties == never connected" do
    it "shows exclamation and text" do
      expect(ct).to receive(:properties).and_return(nil)
      render_inline(described_class.new(card_terminal: ct))
      expect(page).to have_content(Cocard::States.flag(Cocard::States::UNKNOWN))
    end
  end

end
