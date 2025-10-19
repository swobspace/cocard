# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthCheckButtonComponent, type: :component do
  let(:ct) { FactoryBot.create(:card_terminal, :with_mac) }

  describe "without ip" do
    it "does not show button" do
      render_inline(described_class.new(item: ct))
      expect(page).not_to have_css('form[class="button_to"]')
      expect(rendered_content).to be_blank
    end
  end

  describe "with ip 0.0.0.0" do
    it "does not show button" do
      expect(ct).to receive(:ip).at_least(:once).and_return('0.0.0.0')
      render_inline(described_class.new(item: ct))
      expect(page).not_to have_css('form[class="button_to"]')
      expect(rendered_content).to be_blank
    end
  end

  describe "with item.nil?" do
    it "does not show button" do
      render_inline(described_class.new(item: nil))
      expect(page).not_to have_css('form[class="button_to"]')
      expect(rendered_content).to be_blank
    end
  end

  describe "with valid ip" do
    it "does not show button" do
      expect(ct).to receive(:ip).at_least(:once).and_return('198.51.100.4')
      render_inline(described_class.new(item: ct))
      expect(page).to have_css('form[class="button_to"]')
    end
  end


end
