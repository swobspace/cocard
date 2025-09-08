require 'rails_helper'

RSpec.describe KTProxy, type: :model do
  it { is_expected.to belong_to(:card_terminal).optional }
  it { is_expected.to belong_to(:ti_client) }
  it { is_expected.to validate_presence_of(:uuid) }
  it { is_expected.to validate_presence_of(:card_terminal_ip) }
  it { is_expected.to validate_presence_of(:wireguard_ip) }
  it { is_expected.to validate_presence_of(:incoming_ip) }
  it { is_expected.to validate_presence_of(:outgoing_port) }
  it { is_expected.to validate_presence_of(:incoming_ip) }
  it { is_expected.to validate_presence_of(:outgoing_port) }
  

  it 'should get plain factory working' do
    f = FactoryBot.create(:kt_proxy)
    g = FactoryBot.create(:kt_proxy)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:uuid)
    expect(f).to validate_uniqueness_of(:card_terminal_ip)
    expect(f).to validate_uniqueness_of(:incoming_port)
    expect(f).to validate_uniqueness_of(:outgoing_port)
  end

  describe "#to_builder" do
    let(:kt_proxy) { FactoryBot.create(:kt_proxy) }
    let(:json) { kt_proxy.to_builder.target! }

    it { expect(parse_json(json, "id")).to eq(kt_proxy.uuid) }
    it { expect(parse_json(json, "wireguardIp")).to eq("192.0.2.1") }
    it { expect(parse_json(json, "incomingIp")).to eq("192.0.2.2") }
    it { expect(parse_json(json, "incomingPort")).to eq(kt_proxy.incoming_port) }
    it { expect(parse_json(json, "outgoingIp")).to eq("192.0.2.3") }
    it { expect(parse_json(json, "outgoingPort")).to eq(kt_proxy.outgoing_port) }
    it { expect(parse_json(json, "cardTerminalIp")).to eq(kt_proxy.card_terminal_ip.to_s) }
    it { expect(parse_json(json, "cardTerminalPort")).to eq(4742) }
  end

end
