require 'rails_helper'

RSpec.describe Connector, type: :model do
  let(:connector) { FactoryBot.create(:connector, ip: '192.0.2.17') }
  it { is_expected.to have_and_belong_to_many(:clients) }
  it { is_expected.to have_and_belong_to_many(:locations) }
  it { is_expected.to validate_presence_of(:ip) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:connector)
    g = FactoryBot.create(:connector)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:ip)
  end

  describe "#to_s" do
    it { expect(connector.to_s).to match('- / 192.0.2.17') }
  end
end
