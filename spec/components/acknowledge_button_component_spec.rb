# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcknowledgeButtonComponent, type: :component do
  include Rails.application.routes.url_helpers

  let!(:log) { FactoryBot.create(:log, :with_connector) }
  let(:user) { FactoryBot.create(:user) }

  describe "with acknowledge" do
    let!(:ack) { log.acknowledges.create!(user_id: user.id, message: "An acknowledge") }

    it "shows read button" do
      render_inline(described_class.new(notable: log, readonly: true))
      # puts page.native.to_html
      expect(page).to have_css('a[class="btn btn-sm btn-outline-secondary"]')
      expect(page).to have_css(%Q[a[href="#{log_note_path(log, ack)}"]])
    end
  end

  describe "without acknowledge" do
    it "shows ack button" do
      render_inline(described_class.new(notable: log, readonly: false))
      # puts page.native.to_html
      expect(page).to have_css('a[class="btn btn-sm btn-warning"]')
      expect(page).to have_css(%Q[a[href="#{new_log_note_path(log, type: Note.types[:acknowledge])}"]])
    end

    it "readonly - does not show ack button" do
      render_inline(described_class.new(notable: log))
      # puts page.native.to_html
      expect(page).not_to have_css('a[class="btn btn-sm btn-warning"]')
      expect(page).not_to have_css(%Q[a[href="#{new_log_note_path(log, type: Note.types[:acknowledge])}"]])
    end

  end

end
