# frozen_string_literal: true

require "rails_helper"

RSpec.describe Connector::RebootButtonComponent, type: :component do
  include Rails.application.routes.url_helpers
  let(:connector) { FactoryBot.create(:connector) }

  describe "with rebootable connector" do
    before(:each) do
      expect(connector).to receive(:rebootable?).and_return(true)
    end

    it "shows reboot button" do
      render_inline(described_class.new(connector: connector))
      # puts rendered_content
      expect(page).to have_css('button[class="btn btn-danger"]')
      expect(page).to have_css(%Q[form[action="#{reboot_connector_path(connector)}"]])
    end
  end

  describe "with not rebootable connector" do
    before(:each) do
      expect(connector).to receive(:rebootable?).and_return(false)
    end

    it "does not show reboot button" do
      render_inline(described_class.new(connector: connector))
      # puts rendered_content
      expect(rendered_content).to eq('')
    end
  end
end
