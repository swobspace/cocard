require 'rails_helper'

RSpec.describe Connector, type: :model do
  let(:yaml) do
    File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
  end
  let(:connector) do 
    FactoryBot.create(:connector, 
      ip: '192.0.2.17',
      connector_services: YAML.load_file(yaml)
    )
  end
  it { is_expected.to have_many(:contexts).through(:connector_contexts) }
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

  describe "#product_information" do
    it { expect(connector.product_information).to be_kind_of(Cocard::ProductInformation) }
  end

  describe "#service_information" do
    it { expect(connector.service_information).to be_kind_of(Array) }
    it { expect(connector.service_information.first).to be_kind_of(Cocard::Service) }
  end

  describe "#service('EventService')" do
    it { expect(connector.service('EventService')).to be_kind_of(Cocard::Service) }
  end
end
