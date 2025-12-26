# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcknowledgeButtonComponent, type: :component do
  include Rails.application.routes.url_helpers
  let(:user) { FactoryBot.create(:user) }

  describe "Log" do
    let!(:log) { FactoryBot.create(:log, :with_connector) }

    describe "with acknowledge" do
      let!(:ack) { log.acknowledges.create!(user_id: user.id, message: "An acknowledge") }

      it "shows read button" do
        render_inline(described_class.new(notable: log, readonly: true))
        expect(page).to have_css('a[class="btn btn-sm btn-outline-secondary me-1"]')
        expect(page).to have_css(%Q[a[href="#{log_note_path(log, ack)}"]])
      end
    end

    describe "without acknowledge" do
      it "shows ack button" do
        render_inline(described_class.new(notable: log, readonly: false))
        expect(page).to have_css('a[class="btn btn-sm btn-warning me-1"]')
        expect(page).to have_css(%Q[a[href="#{new_log_note_path(log, type: :acknowledge, mail: 1)}"]])
      end

      it "readonly - does not show ack button" do
        render_inline(described_class.new(notable: log))
        expect(page).not_to have_css('a[class="btn btn-sm btn-warning me-1"]')
        expect(page).not_to have_css(%Q[a[href="#{new_log_note_path(log, type: :acknowledge)}"]])
      end
    end
  end

  describe "Connector" do
    let!(:connector) { FactoryBot.create(:connector) }

    describe "with acknowledge" do
      let!(:ack) { connector.acknowledges.create!(user_id: user.id, message: "An acknowledge") }

      it "shows read button" do
        render_inline(described_class.new(notable: connector, readonly: true))
        expect(page).to have_css('a[class="btn btn-sm btn-outline-secondary me-1"]')
        expect(page).to have_css(%Q[a[href="#{connector_note_path(connector, ack)}"]])
      end
    end

    describe "without acknowledge" do
      describe "in error state" do
        before(:each) do
          expect(connector).to receive(:condition).and_return(Cocard::States::WARNING)
        end

        it "shows ack button" do
          render_inline(described_class.new(notable: connector, readonly: false))
          expect(page).to have_css('a[class="btn btn-sm btn-warning me-1"]')
          expect(page).to have_css(%Q[a[href="#{new_connector_note_path(connector, type: :acknowledge, mail: 1)}"]])
        end
      end

      describe "state ok or nothing" do
        before(:each) do
          expect(connector).to receive(:condition).and_return(Cocard::States::OK)
        end

        it "does not shows ack button" do
          render_inline(described_class.new(notable: connector, readonly: false))
          expect(page).not_to have_css('a[class="btn btn-sm btn-warning me-1"]')
          expect(page).not_to have_css(%Q[a[href="#{new_connector_note_path(connector, type: :acknowledge)}"]])
        end
      end

      it "readonly - does not show ack button" do
        render_inline(described_class.new(notable: connector))
        expect(page).not_to have_css('a[class="btn btn-sm btn-warning me-1"]')
        expect(page).not_to have_css(%Q[a[href="#{new_connector_note_path(connector, type: :acknowledge)}"]])
      end
    end
  end
end
