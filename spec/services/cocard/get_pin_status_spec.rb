require 'rails_helper'

module Cocard
  RSpec.describe GetPinStatus do
    # 
    #  create fake response for Cocard::Soap::GetPinStatus
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:pinstatus_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'get_pin_status_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(pinstatus_yml)) }
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

    #
    # card terminal
    #
    let(:ct) do
      FactoryBot.create(:card_terminal, :with_mac, connector: connector)
    end

    #
    # card
    #
    let(:card) do
      FactoryBot.create(:card, 
        card_terminal: ct,
        card_handle: 'ee676b27-5b40-4a40-9c65-979cc3113a1e',
        card_type: 'SMC-B'
      )
    end

    subject do
      Cocard::GetPinStatus.new(context: context, card: card)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::GetPinStatus) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::GetPinStatus).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_err)
        end

         it { expect(subject.call.success?).to be_falsey }
      end

      describe "with empty context" do
        let(:context) { nil }

        it "does not raise an error" do
          expect {
            subject.call
          }.not_to raise_error
        end
        it { expect(subject.call.success?).to be_falsey }
        it { expect(subject.call.error_messages).to include("No Context assigned!") }
      end

      describe "successful call" do
        before(:each) do
          expect(Cocard::SOAP::GetPinStatus).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_truthy }
        it { expect(subject.call.pin_status).to be_kind_of(Cocard::PinStatus) }

        describe 'get some information' do
          before(:each) do
            subject.call
          end
          it { expect(card.card_handle).to eq('ee676b27-5b40-4a40-9c65-979cc3113a1e') }
          it { expect(card.pin_status).to eq("VERIFIABLE") }
        end
      end
    end
  end
end
