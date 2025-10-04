# frozen_string_literal: true

require "rails_helper"

RSpec.describe Connector::TIClientComponent, type: :component do
  include Rails.application.routes.url_helpers
  let(:connector) { FactoryBot.create(:connector) }

  describe "connector.use_ticlient? == false " do
    before(:each) do
      expect(connector).to receive(:use_ticlient?).and_return(false)
    end
    it "don't render" do
      render_inline(described_class.new(connector: connector, readonly: false))
      # puts "/#{rendered_content}/"
      expect(rendered_content).to eq("")
    end
  end

  describe "connector.use_ticlient? == true " do
    before(:each) do
      expect(connector).to receive(:use_ticlient?).and_return(true)
    end

    describe "without ti_client" do
      it "render create ti_client button" do
        render_inline(described_class.new(connector: connector, readonly: false))
        # puts "/#{rendered_content}/"
        expect(page).to have_css('a[class="btn btn-warning"]')
        expect(page).to have_css(%Q[a[href="#{new_connector_ti_client_path(connector)}"]])
      end
      it "don't render create ti_client button if readonly" do
        render_inline(described_class.new(connector: connector, readonly: true))
        # puts "/#{rendered_content}/"
        expect(page).not_to have_css('a[class="btn btn-warning"]')
        expect(page).not_to have_css(%Q[a[href="#{new_connector_ti_client_path(connector)}"]])
        expect(page).to have_content("Kein TI-Client vorhanden")
      end
    end

    describe "with ti_client" do
      let!(:tic) do
        FactoryBot.create(:ti_client, 
          connector: connector,
          name: "TIClient AX45",
          url: "https://localhost:1234"
        )
      end
      it "render ti client data" do
        render_inline(described_class.new(connector: connector, readonly: true))
        expect(page).to have_content("TIClient AX45")
        expect(page).to have_content("https://localhost:1234")
      end
    end

  end
end
