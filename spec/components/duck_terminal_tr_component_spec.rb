# frozen_string_literal: true

require "rails_helper"

RSpec.describe DuckTerminalTrComponent, type: :component do
  let(:ct) { FactoryBot.create(:card_terminal, name: "MyTerm", mac: '11335577AAEE') }
  let(:info) do 
    CardTerminals::RMI::OrgaV1::Info.new( 
      'net_lan_macAddr' => '11335577AAEE',
      'sys_terminalName' => 'MyTerm',
      'sys_ntp_serverIpAddr' => '198.51.100.2',
      'sys_ntp_enabled' => true,
      "update_serverIpAddr" => "192.0.2.10",
    )
  end
  let(:ct_defaults) {{
    ntp_server:  "198.51.100.2",
    ntp_enabled: true,
    tftp_server: "127.0.1.2",
  }}

  before(:each) do
    allow(Cocard).to receive(:card_terminal_defaults).and_return(ct_defaults)
  end

  describe "with :macaddr" do
    it "shows green if mac address matching" do
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :macaddr))
      expect(page).to have_css('th[class="w-25 bg-success bg-opacity-25"]')
    end

    it "shows red if mac address not matching" do
      expect(ct).to receive(:mac).at_least(:once).and_return('123456123456')
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :macaddr))
      expect(page).to have_css('th[class="w-25 bg-danger bg-opacity-50"]')
    end
  end

  describe "with :terminalname" do
    it "shows green if terminalname matching" do
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :terminalname))
      expect(page).to have_css('th[class="w-25 bg-success bg-opacity-25"]')
    end

    it "shows red if mac address not matching" do
      expect(ct).to receive(:name).at_least(:once).and_return('NOMATCH')
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :terminalname))
      expect(page).to have_css('th[class="w-25 bg-danger bg-opacity-50"]')
    end
  end

  describe "with other attributes" do
    it "shows green if ntp_server matching" do
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :ntp_server))
      expect(page).to have_css('th[class="w-25 bg-success bg-opacity-25"]')
    end

    it "shows yellow if tftp_server not matching" do
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :tftp_server))
      expect(page).to have_css('th[class="w-25 bg-warning bg-opacity-50"]')
    end

    it "shows white if tftp_file has no default" do
      render_inline(described_class.new(card_terminal: ct, info: info, attrib: :tftp_file))
      expect(page).to have_css('th[class="w-25 "]')
    end
  end


end
