require 'rails_helper'

RSpec.describe KTProxyConcerns, type: :model do
  let(:kt_proxy) do
    FactoryBot.create(:kt_proxy, 
      uuid: "bf11726a-ad8f-11f0-8247-c025a5b36994",
      name: "ORGA6100-02412345678910",
      wireguard_ip: "198.52.100.1",
      incoming_ip: "192.0.2.1",
      incoming_port: 8080,
      outgoing_ip: "192.0.2.2",
      outgoing_port: 8080,
      card_terminal_ip: "192.0.2.100",
      card_terminal_port: 4742
    )
  end

  describe "#to_jbuilder" do
    it "outputs cardterminals_proxies json format" do
      json = JSON.parse(kt_proxy.to_builder.target!)
      expect(json['id']).to eq("bf11726a-ad8f-11f0-8247-c025a5b36994")
      expect(json["name"]).to eq("ORGA6100-02412345678910")
      expect(json["wireguardIp"]).to eq("198.52.100.1")
      expect(json["incomingIp"]).to eq("192.0.2.1")
      expect(json["incomingPort"]).to eq("8080")
      expect(json["outgoingIp"]).to eq("192.0.2.2")
      expect(json["outgoingPort"]).to eq("8080")
      expect(json["cardTerminalIp"]).to eq("192.0.2.100")
      expect(json["cardTerminalPort"]).to eq("4742")
      expect(json.keys).to contain_exactly(
        "id",
        "name",
        "wireguardIp",
        "incomingIp",
        "incomingPort",
        "outgoingIp",
        "outgoingPort",
        "cardTerminalIp",
        "cardTerminalPort"
      )
    end
    it { expect(kt_proxy.to_builder.target!).to be_kind_of String }
  end

end
