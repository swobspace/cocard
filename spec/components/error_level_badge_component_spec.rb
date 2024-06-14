# frozen_string_literal: true

require "rails_helper"

RSpec.describe ErrorLevelBadgeComponent, type: :component do
  describe "with level = ERROR" do
    it "shows danger badge" do
      render_inline(described_class.new(level: "ERROR"))
      expect(page).to have_css('span[class="badge text-bg-danger"]')
    end
  end

  describe "with level = Critical" do
    it "shows danger badge" do
      render_inline(described_class.new(level: "Critical"))
      expect(page).to have_css('span[class="badge text-bg-danger"]')
    end
  end

  describe "with level = WARN" do
    it "shows warning badge" do
      render_inline(described_class.new(level: "WARN"))
      expect(page).to have_css('span[class="badge text-bg-warning"]')
    end
  end

  describe "with level = Warning" do
    it "shows warning badge" do
      render_inline(described_class.new(level: "Warning"))
      expect(page).to have_css('span[class="badge text-bg-warning"]')
    end
  end

  describe "with level = Info" do
    it "shows light badge" do
      render_inline(described_class.new(level: "Info"))
      expect(page).to have_css('span[class="badge text-bg-light"]')
    end
  end

  describe "with level = Fatal" do
    it "shows alert badge" do
      render_inline(described_class.new(level: "Fatal"))
      expect(page).to have_css('span[class="badge bg-alert"]')
    end
  end

  describe "with level = jibbetnich" do
    it "shows secondary badge" do
      render_inline(described_class.new(level: "jibbetnich"))
      expect(page).to have_css('span[class="badge text-bg-secondary"]')
    end
  end

end
