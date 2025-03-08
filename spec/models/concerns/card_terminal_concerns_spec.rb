require 'rails_helper'

RSpec.describe CardTerminalConcerns, type: :model do
  let(:ct) do
    FactoryBot.create(:card_terminal,
      mac: '000DF808F6AD',
      ip: '127.51.100.17',
      ct_id: "CT_ID_4711",
      displayname: 'CARDTERMINAL 14',
      name: "Product 1704",
      firmware_version: "17.04",
      "id_product": "CardStuff",
      serial: "111111111",
    )
  end

  describe "#update_location_by_ip" do
    context "without network" do
      it "doesn't update location_id" do
        ct.update_location_by_ip
        ct.save; ct.reload
        expect(ct.location_id).to be_nil
      end

      it "doesn't update network_id" do
        ct.update_location_by_ip
        ct.save; ct.reload
        expect(ct.network_id).to be_nil
      end
    end

    context "with matching network" do
      let!(:net) { FactoryBot.create(:network, netzwerk: '127.51.100.16/29') }
      it "updates location_id" do
        ct.update_location_by_ip
        ct.save; ct.reload
        expect(ct.location_id).to eq(net.location_id)
      end

      it "updates networkd_id" do
        ct.update_location_by_ip
        ct.save; ct.reload
        expect(ct.network_id).to eq(net.id)
      end
    end

    context "with non matching network" do
      let!(:net) { FactoryBot.create(:network, netzwerk: '127.51.100.0/29') }
      it "doesn't update location_id" do
        expect {
          ct.update_location_by_ip
        }.not_to change(ct, :location_id)
      end

      it "doesn't update network_id" do
        expect {
          ct.update_location_by_ip
        }.not_to change(ct, :network_id)
      end
    end
  end

  describe "scope :scoped_workplaces" do
    let!(:wps) { FactoryBot.create_list(:workplace, 3) }
    let!(:twp1) do 
      FactoryBot.create(:terminal_workplace,
        card_terminal: ct,
        mandant: 'Mandy',
        client_system: 'SlowMed',
        workplace: wps[0]
      )
    end
    let!(:twp2) do 
      FactoryBot.create(:terminal_workplace,
        card_terminal: ct,
        mandant: 'Mandy',
        client_system: 'FastMed',
        workplace: wps[1]
      )
    end
    let!(:twp3) do 
      FactoryBot.create(:terminal_workplace,
        card_terminal: ct,
        mandant: 'Other',
        client_system: 'SlowMed',
        workplace: wps[2]
      )
    end

    it { expect(ct.scoped_workplaces('Mandy', 'SlowMed')).to contain_exactly(wps[0]) }
    it { expect(ct.scoped_workplaces('Mandy', 'FastMed')).to contain_exactly(wps[1]) }
    it { expect(ct.scoped_workplaces('Other', 'SlowMed')).to contain_exactly(wps[2]) }
  end

  describe "smc-xx" do
    let(:c1) { FactoryBot.create(:card, card_type: 'SMC-KT') }
    let(:c2) { FactoryBot.create(:card, card_type: 'SMC-B') }
    let!(:slot1) do
      FactoryBot.create(:card_terminal_slot,
        card_terminal: ct,
        slotid: 1,
        card: c1
      )
    end
    let!(:slot2) do
      FactoryBot.create(:card_terminal_slot,
        card_terminal: ct,
        slotid: 2,
        card: c2
      )
    end

    describe "#smcb" do
      it { expect(ct.smcb).to contain_exactly(c2) }
    end

    describe "#has_smcb?" do
      it { expect(ct.has_smcb?).to be_truthy }
    end

    describe "#smckt" do
      it { expect(ct.smckt).to eq(c1) }
    end
  end

  describe "#default_idle_message" do
    let(:conn) { FactoryBot.create(:connector, short_name: 'K128') }
    let(:ct) do 
      FactoryBot.create(:card_terminal,
        name: 'NAME-01234567890',
        mac: '000DF808F6AD',
        connector: conn
      )
    end

    describe "with smcb" do
      before(:each) { expect(ct).to receive(:has_smcb?).and_return(true) }
      it { expect(ct.default_idle_message).to eq("K128 567890") }
    end

    describe "without smcb" do
      before(:each) { expect(ct).to receive(:has_smcb?).and_return(false) }
      it { expect(ct.default_idle_message).to eq("08F6AD") }
    end
  end

  describe "#to_liquid" do
    let(:connector) do
      FactoryBot.create(:connector, name: 'TIK-123-XXX', short_name: 'K128')
    end
    let(:network) { FactoryBot.create(:network, netzwerk: "127.51.100.0/24") }
    let(:location) { FactoryBot.create(:location, lid: 'AXC') }

    before(:each) do
      expect(ct).to receive(:connector).at_least(:once).and_return(connector)
      expect(ct).to receive(:network).and_return(network)
      expect(ct).to receive(:location).and_return(location)
    end

    it "returns hash" do
      expect(ct.to_liquid).to include(
        "has_smcb?" => false,
        "displayname" => "CARDTERMINAL 14",
        "name" => "Product 1704",
        "location" => "AXC",
        "ct_id" => "CT_ID_4711",
        "mac" => "000DF808F6AD",
        "ip" => "127.51.100.17",
        "connector" => "TIK-123-XXX",
        "connector_short_name" => "K128",
        "firmware_version" => "17.04",
        "serial" => "111111111",
        "id_product" => "CardStuff",
        "network" => "127.51.100.0/24"
      )
    end
  end

  describe "#supports_rmi?" do
    describe "with noname terminal" do    
      it { expect(ct.supports_rmi?).to be_falsey }
      it { expect(ct.supports_rmi?).not_to be_nil }
    end

    describe "with supported terminal" do
      let(:product_information) { instance_double(Cocard::ProductInformation) }
      let(:ct) do
        FactoryBot.create(:card_terminal, :with_mac,
          firmware_version: '3.9.1'
        )
      end
      it "supports_rmi? is true" do
        expect(ct).to receive(:product_information).and_return(product_information)
        expect(product_information).to receive(:product_code).and_return('ORGA6100')
        expect(ct.supports_rmi?).to be_truthy
      end
    end
  end

  describe "#rebootable?" do
    it { expect(ct.rebootable?).to be_falsey }
  end

  describe "#rebooted?" do
    it "no if rebooted_at.nil?" do
      expect(ct).to receive(:rebooted_at).and_return(nil)
      expect(ct.rebooted?).to be_falsey
    end

    it "current rebooted_at" do
      expect(ct).to receive(:rebooted_at).at_least(:once).and_return(Time.current)
      expect(ct.rebooted?).to be_truthy
    end

    it "old rebooted_at" do
      ct.update(rebooted_at: 1.hour.before(Time.current))
      ct.reload
      expect(ct.rebooted?).to be_falsey
      ct.reload
      expect(ct.rebooted_at).to be_nil
    end
  end

  describe "#reboot_active?" do
    it "no if rebooted_at.nil?" do
      expect(ct).to receive(:rebooted_at).and_return(nil)
      expect(ct.reboot_active?).to be_falsey
    end

    it "current rebooted_at" do
      expect(ct).to receive(:rebooted_at).at_least(:once).and_return(Time.current)
      expect(ct.reboot_active?).to be_truthy
    end

    it "old rebooted_at" do
      ct.update(rebooted_at: 2.minutes.before(Time.current))
      ct.reload
      expect(ct.reboot_active?).to be_falsey
    end
  end
end
