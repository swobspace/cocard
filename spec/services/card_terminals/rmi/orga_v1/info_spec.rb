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
      "vendor_serialNumber" => "SERIAL1234"
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
  end
end
