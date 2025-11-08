require 'rails_helper'

RSpec.describe TIClient, type: :model do
  let(:ticlient) { FactoryBot.create(:ti_client, name: "TIClient_01") }
  it { is_expected.to belong_to(:connector) }
  it { is_expected.to have_many(:kt_proxies).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of(:connector_id) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:url) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:ti_client)
    g = FactoryBot.create(:ti_client)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:url)
    expect(f).to validate_uniqueness_of(:connector_id)
  end

  it "client_secret is encrypted" do
    ticlient.update(client_secret: "StrengGeheim")
    ticlient.reload
    expect(ticlient.encrypted_attribute?(:client_secret)).to be_truthy
  end

  describe "#to_s" do
    it { expect(ticlient.to_s).to match('TIClient_01') }
  end


end
