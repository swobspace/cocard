require 'rails_helper'

RSpec.describe Network, type: :model do
  let(:network) { FactoryBot.create(:network, netzwerk: '192.0.2.0/24') }
  it { is_expected.to belong_to(:location) }
  it { is_expected.to validate_presence_of(:netzwerk) }
  it { is_expected.to define_enum_for(:accessibility).with_values(nothing: -1, ping: 0) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:network, netzwerk: '192.0.2.0/29')
    g = FactoryBot.create(:network, netzwerk: '192.0.2.8/29')
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:netzwerk)
  end

  describe "#to_s" do
    it { expect(network.to_s).to match('192.0.2.0/24') }
  end

end
