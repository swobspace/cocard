require 'rails_helper'

RSpec.describe Client, type: :model do
  let(:client) { FactoryBot.create(:client, name: 'ACME') }
  it { is_expected.to have_and_belong_to_many(:connectors) }
  it { is_expected.to validate_presence_of(:name) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:client)
    g = FactoryBot.create(:client)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:name).case_insensitive
  end

  describe "#to_s" do
    it { expect(client.to_s).to match('ACME') }
  end
end
