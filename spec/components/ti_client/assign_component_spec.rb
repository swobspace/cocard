# frozen_string_literal: true

require "rails_helper"

RSpec.describe TIClient::AssignComponent, type: :component do
  let(:ti_client) { FactoryBot.create(:ti_client) }
  let!(:ct) { FactoryBot.create(:card_terminal, :with_mac) }
  let(:terminal) do
    RISE::TIClient::Konnektor::Terminal.new({
         "CORRELATION" => 'BEKANNT',
         "CTID" => ct.rawmac.to_s
    })
  end

  describe "with correlation BEKANNT" do
    it "shows plus button" do
      render_inline(described_class.new(ti_client: ti_client, terminal: terminal))
      expect(page).to have_css('i[class="fa-solid fa-fw fa-plus"]')
    end
  end

  describe "with correlation ZUGEWIESEN" do
    it "shows plus button" do
      expect(terminal).to receive(:correlation).at_least(:once).and_return('ZUGEWIESEN')
      render_inline(described_class.new(ti_client: ti_client, terminal: terminal))
      expect(page).to have_css('i[class="fa-solid fa-fw fa-link"]')
    end
  end

  describe "with correlation GEPAIRT" do
    it "shows play button" do
      expect(terminal).to receive(:correlation).at_least(:once).and_return('GEPAIRT')
      render_inline(described_class.new(ti_client: ti_client, terminal: terminal))
      expect(page).to have_css('i[class="fa-solid fa-fw fa-play"]')
    end
  end

  describe "with correlation AKTIV, connected == true" do
    it "shows plus button" do
      expect(terminal).to receive(:correlation).at_least(:once).and_return('AKTIV')
      expect(terminal).to receive(:connected).at_least(:once).and_return(true)
      render_inline(described_class.new(ti_client: ti_client, terminal: terminal))
      expect(page).to have_css('i[class="fa-solid fa-fw fa-check"]')
      expect(page).to have_css('button[class="btn btn-sm btn-success me-1"]')
    end
  end

  describe "with correlation AKTIV, connected == false" do
    it "shows plus button" do
      expect(terminal).to receive(:correlation).at_least(:once).and_return('AKTIV')
      expect(terminal).to receive(:connected).at_least(:once).and_return(false)
      render_inline(described_class.new(ti_client: ti_client, terminal: terminal))
      expect(page).to have_css('i[class="fa-solid fa-fw fa-check"]')
      expect(page).to have_css('button[class="btn btn-sm btn-warning me-1"]')
    end
  end

end
