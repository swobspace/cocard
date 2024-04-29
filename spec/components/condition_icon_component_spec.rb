# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConditionIconComponent, type: :component do
  let(:connector) { FactoryBot.create(:connector) }

  describe "with condition = CRITICAL" do
    it "shows CRITICAL button" do
      expect(connector).to receive(:condition).at_least(:once)
                                              .and_return(Cocard::States::CRITICAL)
      render_inline(described_class.new(item: connector))
      expect(page).to have_css('button[class="btn btn-danger"]')
    end
  end

  describe "with condition = UNKNOWN" do
    it "shows UNKNOWN button" do
      expect(connector).to receive(:condition).at_least(:once)
                                              .and_return(Cocard::States::UNKNOWN)
      render_inline(described_class.new(item: connector))
      expect(page).to have_css('button[class="btn btn-info"]')
    end
  end
end
