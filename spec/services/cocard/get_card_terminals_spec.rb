require 'rails_helper'

module Cocard
  RSpec.describe GetCardTerminals do
    # 
    #  create fake response for Cocard::Soap::GetCardTerminals
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:terminals_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'get_card_terminals_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(terminals_yml)) }
    let(:fake_err) { Fake.new(false, ['something is wrong'], nil) }

    #
    # connector and context
    #
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['SDS_IP'],
        connector_services: YAML.load_file(connector_yml),
        vpnti_online: true
      )
    end

    let(:context) { FactoryBot.create(:context) }

    subject do
      Cocard::GetCardTerminals.new(connector: connector, context: context)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::GetCardTerminals) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::GetCardTerminals).to receive(:new).and_return(soap)
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
          expect(Cocard::SOAP::GetCardTerminals).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.card_terminals.first).to be_kind_of(Cocard::CardTerminal) }
        it 'updates last_check' do
          expect do
            subject.call
          end.to change(connector, :last_check)
        end

        it 'updates last_check_ok' do
          expect do
            subject.call
          end.to change(connector, :last_check_ok)
        end

        describe 'get some information' do
          let(:ct) { subject.call.card_terminals.first }
          it { expect(ct.mac).to eq('00-0D-F8-0C-86-52') }
          it { expect(ct.name).to eq('ORGA6100-0241000000B692') }
        end
      end
    end
  end
end
