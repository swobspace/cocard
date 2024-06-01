require 'rails_helper'

RSpec.describe NetworkConcerns, type: :model do
  let(:network) do
    FactoryBot.create(:network, 
      netzwerk: '192.0.2.32/28'
    )
  end

  describe "#to_cidr_s" do
    it { expect(network.to_cidr_s).to eq('192.0.2.32/28') }
  end

  describe "::best_match(ip)" do
    let!(:n1) { FactoryBot.create(:network, netzwerk: '192.0.2.0/24') }
    let!(:n2) { FactoryBot.create(:network, netzwerk: '192.0.2.32/27') }
    let!(:n3) { FactoryBot.create(:network, netzwerk: '192.168.0.0/24') }
    let!(:n4) { FactoryBot.create(:network, netzwerk: '192.168.0.0/25') }

    it { expect(Network.best_match('192.0.2.35')).to contain_exactly(n2) }
    it { expect(Network.best_match('192.0.2.17')).to contain_exactly(n1) }
    it { expect(Network.best_match('192.168.0.17')).to contain_exactly(n4) }
    it { expect(Network.best_match('198.51.100.4')).to contain_exactly() }
    it { expect(Network.best_match(nil)).to contain_exactly() }
  end

end
