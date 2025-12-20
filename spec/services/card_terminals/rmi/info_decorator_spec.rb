# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe RMI::InfoDecorator do
    let(:ct_defaults) {{
      ntp_server:  "198.51.100.2",
      ntp_enabled: true,
      tftp_server: "127.0.1.2",
      tftp_file:   "firmware.dat"
    }}

    let(:properties) {{
      "net_lan_macAddr" => '00:11:22:33:44:aa',
      "sys_terminalName" => "ORGA-6100-Terminalname",
      "net_lan_dhcpEnabled" => true,
      "net_lan_ipAddr" => "127.1.2.3",
      "net_lan_ipAddrStatic" => "192.168.1.1",
      "net_lan_ipAddrDhcp" => "127.1.2.3",
      "rmi_smcb_pinEnabled" => true, 
      "rmi_pairingEHealthTerminal_enabled" => true,
      "update_serverIpAddr" => "192.0.2.10",
      "update_fileName" => "firmware.dat",
      "sys_ntp_serverIpAddr" => '192.0.2.20',
      "sys_ntp_enabled" => true,
      "vendor_serialNumber" => "SERIAL1234",
      "sys_uptime_durationTotal" => "340",
      "sys_uptime_durationSinceBoot" => "12",
      "card_slot1_plugCycles" => "101",
      "card_slot2_plugCycles" => "102",
      "card_slot3_plugCycles" => "103",
      "card_slot4_plugCycles" => "104",
      "card_smkt_iccsn" => '80276123456789011111',
      "card_smkt_version" => '4.4.1',
      "card_smkt_slotNum" => '4',
      "card_smkt_autType" => 'RSA',
      "card_smkt_autCxd" => '11.11.2026',
      "card_smkt_aut2Type" => 'ECC',
      "card_smkt_aut2Cxd" => '30.08.2030',
    }}

    let(:info) { CardTerminals::RMI::OrgaV1::Info.new(properties) }
    subject    { CardTerminals::RMI::InfoDecorator.new(info) }

    it { expect(subject.terminalname).to eq("ORGA-6100-Terminalname") }
    it { expect(subject.dhcp_enabled).to eq(true) }
    it { expect(subject.macaddr).to eq("0011223344AA") }
    it { expect(subject.current_ip).to eq("127.1.2.3") }
    it { expect(subject.dhcp_ip).to eq("127.1.2.3") }
    it { expect(subject.static_ip).to eq("192.168.1.1") }
    it { expect(subject.remote_pin_enabled).to eq(true) }
    it { expect(subject.remote_pairing_enabled).to eq(true) }
    it { expect(subject.ntp_enabled).to eq(true) }
    it { expect(subject.ntp_server).to eq("192.0.2.20") }
    it { expect(subject.tftp_server).to eq("192.0.2.10") }
    it { expect(subject.tftp_file).to eq("firmware.dat") }
    it { expect(subject.serial).to eq("SERIAL1234") }
    it { expect(subject.uptime_total).to eq("340") }
    it { expect(subject.uptime_reboot).to eq("12") }
    it { expect(subject.slot1_plug_cycles).to eq("101") }
    it { expect(subject.slot2_plug_cycles).to eq("102") }
    it { expect(subject.slot3_plug_cycles).to eq("103") }
    it { expect(subject.slot4_plug_cycles).to eq("104") }
    it { expect(subject.smckt_iccsn).to eq("80276123456789011111") }
    it { expect(subject.smckt_version).to eq("4.4.1") }
    it { expect(subject.smckt_slot).to eq("4") }
    it { expect(subject.smckt_auth1_type).to eq("RSA") }
    it { expect(subject.smckt_auth1_expiration).to eq("2026-11-11".to_date) }
    it { expect(subject.smckt_auth1_expiration).to be_kind_of(Date) }
    it { expect(subject.smckt_auth2_type).to eq("ECC") }
    it { expect(subject.smckt_auth2_expiration).to eq("2030-08-30".to_date) }
    it { expect(subject.smckt_auth2_expiration).to be_kind_of(Date) }

    describe "with some defaults" do
      before(:each) do
        allow(Cocard).to receive(:card_terminal_defaults).and_return(ct_defaults)
      end

      it { expect(subject.terminalname_default).to be_nil }
      it { expect(subject.dhcp_enabled_default).to be_nil }
      it { expect(subject.macaddr_default).to be_nil }
      it { expect(subject.ntp_enabled_default).to eq(true) }
      it { expect(subject.ntp_server_default).to eq("198.51.100.2") }
      it { expect(subject.tftp_server_default).to eq("127.0.1.2") }
      it { expect(subject.tftp_file_default).to eq("firmware.dat") }

      it { expect(subject.terminalname_eq?('MURKS')).to be_falsey }
      it { expect(subject.dhcp_enabled_ok?).to eq(Cocard::States::NOTHING) }
      it { expect(subject.macaddr_eq?('0011223344AA')).to be_truthy}
      it { expect(subject.ntp_enabled_ok?).to eq(Cocard::States::OK) }
      it { expect(subject.ntp_server_ok?).to eq(Cocard::States::WARNING) }
      it { expect(subject.tftp_server_ok?).to eq(Cocard::States::WARNING) }
      it { expect(subject.tftp_file_ok?).to eq(Cocard::States::OK) }
    end
  end
end
