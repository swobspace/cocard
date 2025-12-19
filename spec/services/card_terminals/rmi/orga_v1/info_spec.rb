# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe RMI::OrgaV1::Info do
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
      "update_fileName" => "somestuff.boot",
      "sys_ntp_serverIpAddr" => '192.0.2.20',
      "sys_ntp_enabled" => true,
      "vendor_serialNumber" => "SERIAL1234",
      "sys_uptime_durationTotal" => "340",
      "sys_uptime_durationSinceBoot" => "12",
      "card_slot1_plugCycles" => "101",
      "card_slot2_plugCycles" => "102",
      "card_slot3_plugCycles" => "103",
      "card_slot4_plugCycles" => "104",
      "vendor_deviceManufacturerId" => 'INGHC',
      "vendor_deviceModelName" => 'ORGA6100',
      "card_smkt_iccsn" => '80276123456789011111',
      "card_smkt_version" => '4.4.1',
      "card_smkt_slotNum" => '4',
      "card_smkt_autType" => 'RSA',
      "card_smkt_autCxd" => '11.11.2026',
      "card_smkt_aut2Type" => 'ECC',
      "card_smkt_aut2Cxd" => '30.08.2030',
    }}

    subject { CardTerminals::RMI::OrgaV1::Info.new(properties) }

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
    it { expect(subject.tftp_file).to eq("somestuff.boot") }
    it { expect(subject.serial).to eq("SERIAL1234") }
    it { expect(subject.uptime_total).to eq("340") }
    it { expect(subject.uptime_reboot).to eq("12") }
    it { expect(subject.slot1_plug_cycles).to eq("101") }
    it { expect(subject.slot2_plug_cycles).to eq("102") }
    it { expect(subject.slot3_plug_cycles).to eq("103") }
    it { expect(subject.slot4_plug_cycles).to eq("104") }
    it { expect(subject.product_vendor_id).to eq("INGHC") }
    it { expect(subject.product_code).to eq("ORGA6100") }
    it { expect(subject.identification).to eq("INGHC-ORGA6100") }
    it { expect(subject.smckt_iccsn).to eq("80276123456789011111") }
    it { expect(subject.smckt_version).to eq("4.4.1") }
    it { expect(subject.smckt_slot).to eq("4") }
    it { expect(subject.smckt_auth1_type).to eq("RSA") }
    it { expect(subject.smckt_auth1_expiration).to eq("2026-11-11".to_date) }
    it { expect(subject.smckt_auth1_expiration).to be_kind_of(Date) }
    it { expect(subject.smckt_auth2_type).to eq("ECC") }
    it { expect(subject.smckt_auth2_expiration).to eq("2030-08-30".to_date) }
    it { expect(subject.smckt_auth2_expiration).to be_kind_of(Date) }

    it "contains all attributes" do
      expect(CardTerminals::RMI::OrgaV1::Info::ATTRIBUTES).to contain_exactly(
        *%i[
          terminalname
          dhcp_enabled
          macaddr
          current_ip
          static_ip
          dhcp_ip
          remote_pin_enabled
          remote_pairing_enabled
          ntp_enabled
          ntp_server
          tftp_server
          tftp_file
          firmware_version
          firmware_builddate
          serial
          uptime_total
          uptime_reboot
          slot1_plug_cycles
          slot2_plug_cycles
          slot3_plug_cycles
          slot4_plug_cycles
          identification
          smckt_iccsn
          smckt_version
          smckt_slot
          smckt_auth1_type
          smckt_auth1_expiration
          smckt_auth2_type
          smckt_auth2_expiration
        ]
      )
    end
  end
end
