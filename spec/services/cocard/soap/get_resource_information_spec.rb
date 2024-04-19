require 'rails_helper'

module Cocard::SOAP
  RSpec.describe GetResourceInformation do
    let(:yaml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        connector_services: YAML.load_file(yaml)
      )
    end

    subject do
      Cocard::SOAP::GetResourceInformation.new(
        connector: connector,
        mandant: 'Ein1',
        client_system_id: 'iMedOne',
        workplace_id: 'Konnektor'
      )
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      it { puts subject.call }
    end
  end
end
