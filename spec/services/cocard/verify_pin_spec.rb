require 'rails_helper'

module Cocard
  RSpec.describe VerifyPin do
    # 
    #  create fake response for Cocard::Soap::VerifyPin
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector.sds')
    end

    let(:verifypin_yml) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'verify_pin_response.yml')
      File.read(file)
    end

    let(:fake_ok)  { Fake.new(true, [], 
                              YAML.unsafe_load(verifypin_yml)) }
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

    let(:slot) do
      FactoryBot.create(:card_terminal_slot, card_terminal: ct, slotid: 1)
    end

    #
    # card
    #
    let(:card) do
      FactoryBot.create(:card, 
        card_terminal_slot: slot,
        card_handle: 'ee676b27-5b40-4a40-9c65-979cc3113a1e',
        card_type: 'SMC-B'
      )
    end

    subject do
      Cocard::VerifyPin.new(context: context, card: card)
    end

    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe '#call' do
      let(:soap) { instance_double(Cocard::SOAP::VerifyPin) }
      describe "return error if not successful" do
        before(:each) do
          expect(Cocard::SOAP::VerifyPin).to receive(:new).and_return(soap)
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
          card.contexts << context
          expect(Cocard::SOAP::VerifyPin).to receive(:new).and_return(soap)
          expect(soap).to receive(:call).and_return(fake_ok)
        end
        it { expect(subject.call.success?).to be_falsey }
        it { expect(subject.call.pin_verify).to be_kind_of(Cocard::PinVerify) }

        it "creates an log entry" do
          expect {
            subject.call
          }.to change(Log, :count).by(1)
        end

        describe 'get some information' do
          let!(:result) { subject.call }
          it { expect(result.pin_verify.status).to eq("Warning") }
          it { expect(result.pin_verify.pin_result).to eq("ERROR") }
          it { card.reload; expect(card.logs.first.action).to match("VerifyPin / ") }
          it { card.reload; expect(card.logs.first.message).to match("ERROR; Timeout bei der PIN-Eingabe") }
        end
      end
    end
  end
end
