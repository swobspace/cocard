require 'rails_helper'

RSpec.describe CardTerminalConcerns, type: :model do
  let(:ct) do
    FactoryBot.create(:card_terminal, :with_mac,
      ip: '127.51.100.17'
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

  describe "#smcb" do
    let!(:c1) { FactoryBot.create(:card, card_terminal: ct, card_type: 'SMC-KT') }
    let!(:c2) { FactoryBot.create(:card, card_terminal: ct, card_type: 'SMC-B') }
    it { expect(ct.smcb).to contain_exactly(c2) }
  end

  describe "#smckt" do
    let!(:c1) { FactoryBot.create(:card, card_terminal: ct, card_type: 'SMC-KT') }
    let!(:c2) { FactoryBot.create(:card, card_terminal: ct, card_type: 'SMC-B') }
    it { expect(ct.smckt).to eq(c1) }
  end
end
