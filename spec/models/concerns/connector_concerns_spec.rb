require 'rails_helper'

RSpec.describe ConnectorConcerns, type: :model do
  # 
  # connector
  # 
  let(:connector_yml) do
    File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
  end   

  let(:connector) do
    FactoryBot.create(:connector,
      ip: ENV['SDS_IP'],
      connector_services: YAML.load_file(connector_yml),
      vpnti_online: true
    )
  end

  describe "with a real connector" do
    describe "#rebootable?" do
      it { expect(connector.rebootable?).to be_truthy }
    end
  end

  describe "with other connector" do
    let(:connector) { FactoryBot.create(:connector) }
    describe "#rebootable?" do
      it { expect(connector.rebootable?).to be_falsey }
    end
  end

end
