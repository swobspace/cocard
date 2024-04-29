# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConditionBadgeComponent, type: :component do
  let(:connector) { FactoryBot.create(:connector) }

  describe "with condition = CRITICAL" do
    it "shows CRITICAL button" do
      render_inline(described_class.new(state: 2, count: 2))
      expect(page).to have_css('button[class="btn btn-danger"]')
    end
  end

  describe "with condition = UNKNOWN" do
    it "shows UNKNOWN button" do
      render_inline(described_class.new(state: 3, count: 1))
      expect(page).to have_css('button[class="btn btn-info"]')
    end
  end
end
