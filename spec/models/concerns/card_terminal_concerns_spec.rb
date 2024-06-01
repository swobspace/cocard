require 'rails_helper'

RSpec.describe CardTerminalConcerns, type: :model do
  let(:ct) do
    FactoryBot.create(:card_terminal,
      ip: '198.51.100.17'
    )
  end

  describe "#update_location_by_ip" do
    context "without network" do
      it "doesn't update location_id" do
        expect {
          ct.update_location_by_ip
        }.not_to change(ct, :location_id)
      end
    end

    context "with matching network" do
      let!(:net) { FactoryBot.create(:network, netzwerk: '198.51.100.16/29') }
      it "updates location_id" do
        expect {
          ct.update_location_by_ip
        }.to change(ct, :location_id)
       expect(ct.location_id).to eq(net.location_id)
      end
    end

    context "with non matching network" do
      let!(:net) { FactoryBot.create(:network, netzwerk: '198.51.100.0/29') }
      it "doesn't update location_id" do
        expect {
          ct.update_location_by_ip
        }.not_to change(ct, :location_id)
      end
    end
  end

end
