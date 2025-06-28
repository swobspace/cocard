# frozen_string_literal: true

require "rails_helper"

# class CheckValueComponent < ViewComponent::Base
#   def initialize(value:, condition:, message:, icon: true, level: :info)
#
RSpec.describe CheckValueComponent, type: :component do
  describe "with condition false" do
    it "shows no message, no bg color" do
      render_inline(described_class.new(value: '99.7.2', 
                                        condition: false,
                                        message: 'MyMessage',
                                        icon: true,
                                        level: :info))
      # puts rendered_content
      expect(page).to have_content("✅ 99.7.2")
      expect(page).to have_content("MyMessage")
      expect(page).to have_css('span[class=""]')
    end
  end

  describe "with condition true" do
    it "shows message and bg color bg-info" do
      render_inline(described_class.new(value: '99.7.2', 
                                        condition: true,
                                        message: 'MyMessage',
                                        icon: true,
                                        level: :info))
      # puts rendered_content
      expect(page).to have_content("⚠ 99.7.2")
      expect(page).to have_content("MyMessage")
      expect(page).to have_css('span[class="badge text-bg-info opacity-75"]')
    end
  end

  describe "with condition true and level :danger" do
    it "shows message and bg color bg-danger" do
      render_inline(described_class.new(value: '99.7.2', 
                                        condition: true,
                                        message: 'MyMessage',
                                        icon: true,
                                        level: :critical))
      # puts rendered_content
      expect(page).to have_content("⚠ 99.7.2")
      expect(page).to have_content("MyMessage")
      expect(page).to have_css('span[class="badge text-bg-danger opacity-75"]')
    end
  end

  describe "with icon false" do
    it "shows no icon" do
      render_inline(described_class.new(value: '99.7.2', 
                                        condition: false,
                                        message: 'MyMessage',
                                        icon: false,
                                        level: :info))
      # puts rendered_content
      expect(page).not_to have_content("✅ 99.7.2")
      expect(page).to have_content("99.7.2")
      expect(page).to have_content("MyMessage")
      expect(page).to have_css('span[class=""]')
    end
  end


end
