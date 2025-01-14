# frozen_string_literal: true

require "rails_helper"

RSpec.describe MuteButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  describe "with unmuted mutable" do
    let(:mutable) { FactoryBot.create(:single_picture, muted: false) }
    it "shows mute button" do
      render_inline(described_class.new(mutable: mutable, readonly: false, small: true))
      expect(page).to have_css('button[class="btn btn-sm btn-warning"]')
    end
  end

  describe "with muted mutable" do
    let(:mutable) { FactoryBot.create(:single_picture, muted: true) }
    it "shows unmute button" do
      render_inline(described_class.new(mutable: mutable, readonly: false, small: true))
      expect(page).to have_css('button[class="btn btn-sm btn-outline-secondary"]')
    end
  end

end
