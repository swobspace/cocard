require 'rails_helper'

module Cocard
  RSpec.describe GetResourceInformation do
    # 
    #  create fake response for Cocard::Soap::GetResourceInformation
    #
    Fake = Struct.new(:success?, :error_messages, :response)
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:resource_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'get_resource_information_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(resource_yml)[:get_resource_information_response]) }
    let(:fake_err) { Fake.new(false, ['something is wrong'], nil) }

    #
    # connector and context
    #
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        connector_services: YAML.load_file(connector_yml)
      )
    end

    let(:context) { FactoryBot.create(:context) }
    let(:connector_context) do
      ConnectorContext.create!(connector: connector, context: context)
    end

    subject do
      Cocard::GetResourceInformation.new(connector_context: connector_context)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::GetResourceInformation) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::GetResourceInformation).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_err)
          connector.update(soap_request_success: true)
        end

        it { expect(subject.call.success?).to be_falsey }

        describe "Ping failed" do
          it "update connector_condition" do
            expect(connector).to receive(:up?).and_return(false)
            expect {
              subject.call
            }.to change(connector, :condition).to(Cocard::States::CRITICAL)
          end
        end

        describe "Ping ok" do
          it "update connector_condition" do
            expect(connector).to receive(:up?).and_return(true)
            expect {
              subject.call
            }.to change(connector, :condition).to(Cocard::States::UNKNOWN)
          end
        end
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::GetResourceInformation).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.resource_information).to be_kind_of(Cocard::ResourceInformation) }
      end
    end
  end
end
