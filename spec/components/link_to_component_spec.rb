# frozen_string_literal: true

require "rails_helper"

RSpec.describe LinkToComponent, type: :component do
  let(:connector) { FactoryBot.create(:connector, id: 3) }

  describe "with item present" do
    it "renders link with :to_s" do
      render_inline(described_class.new(item: connector))
      expect(page).to have_css('a[class="primary-link"]')
      expect(page).to have_css('a[href="/connectors/3"]', text: connector.to_s)
    end

    it "renders link with :name" do
      render_inline(described_class.new(item: connector, label_method: :name))
      expect(page).to have_css('a[class="primary-link"]')
      expect(page).to have_css('a[href="/connectors/3"]', text: connector.name)
    end
  end

  describe "with no item" do
    it "renders nothing" do
      render_inline(described_class.new(item: nil))
      expect(rendered_content).to eq("")
    end
  end
end
