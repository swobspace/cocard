require 'rails_helper'

module Cocard
  RSpec.describe NewKTProxy, type: :model do
    let(:ct) do
      FactoryBot.create(:card_terminal, :with_mac,
        ip: '203.0.113.1',
        name: 'My Card Terminal',
      )
    end
    let(:ktproxy_defaults) do
      { "wireguard_ip"=>"198.51.100.99",
        "incoming_ip"=>"192.0.2.1",
        "incoming_port_range"=>"8101:8999",
        "outgoing_ip"=>"192.0.2.2",
        "outgoing_port_range"=>"8101:8999",
        "card_terminal_port"=>4742 }
    end

    subject { Cocard::NewKTProxy.new(card_terminal: ct, defaults: ktproxy_defaults) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::NewKTProxy.new() }.to raise_error(ArgumentError)
      end
    end

    describe "with real card terminal" do
      it { expect(subject).to be_kind_of Cocard::NewKTProxy }
      describe "#attributes" do
        let(:attributes) { subject.attributes }
        it { expect(attributes).to include(
               name: 'My Card Terminal',
               wireguard_ip: "198.51.100.99",
               card_terminal_ip: '203.0.113.1',
               card_terminal_port: 4742
             )}
      end
    end

  end
end
