require 'rails_helper'

module Cocard
  RSpec.describe PinVerificationRunner do
    subject(:runner) { described_class.new(card: card) }

    let(:card) do
      instance_double(Card,
                      card_terminal: terminal,
                      iccsn: '80276883110000123456')
    end
    let(:terminal) { instance_double(CardTerminal, rmi: rmi) }
    let(:rmi) do
      instance_double(CardTerminals::RMI,
                      coordinated_verify_pin_available?: true,
                      coordinated_verify_pin_supported?: true)
    end
    let(:context) { instance_double(Context) }
    let(:verification_result) do
      Cocard::VerifyPin::Result.new(success?: true, error_messages: [], pin_verify: nil)
    end

    describe '#verify_contexts' do
      it 'returns the yielded verification result from a coordinated success' do
        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
          expect(block.call).to eq(verification_result)
          CardTerminals::RMI::Status.success('ok')
        end

        result = runner.verify_contexts { |_verifier| verification_result }

        expect(result).to eq(described_class::Result.new(success?: true, error_messages: [], value: verification_result))
      end

      it 'lets a coordinated success status value override the yielded block value' do
        status_value = ['status value']

        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
          block.call
          CardTerminals::RMI::Status.success('ok', status_value)
        end

        result = runner.verify_contexts { |_verifier| verification_result }

        expect(result).to eq(described_class::Result.new(success?: true, error_messages: [], value: status_value))
      end

      it 'uses plain VerifyPin inside a coordinated block' do
        verify_pin = instance_double(Cocard::VerifyPin, call: verification_result)

        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
          block.call
          CardTerminals::RMI::Status.success('ok')
        end
        expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)

        result = runner.verify_contexts { |verifier| verifier.call(context) }

        expect(result).to eq(described_class::Result.new(success?: true, error_messages: [], value: verification_result))
      end

      it 'returns a failure result when coordinated verification fails' do
        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once
          .and_return(CardTerminals::RMI::Status.failure('coordinated verification failed'))

        result = runner.verify_contexts { |_verifier| verification_result }

        expect(result).to eq(described_class::Result.new(success?: false, error_messages: ['coordinated verification failed'], value: nil))
      end

      it 'returns a clear failure result when coordinated verification is unsupported' do
        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once
          .and_return(CardTerminals::RMI::Status.unsupported)

        result = runner.verify_contexts { |_verifier| verification_result }

        expect(result).to eq(
          described_class::Result.new(
            success?: false,
            error_messages: ['Coordinated PIN verification is not supported by this card terminal.'],
            value: nil
          )
        )
      end

      it 'uses the legacy ORGA-shaped job, wait, and direct VerifyPin path' do
        allow(rmi).to receive(:coordinated_verify_pin_available?).and_return(false)
        allow(rmi).to receive(:coordinated_verify_pin_supported?).and_return(false)
        verify_pin = instance_double(Cocard::VerifyPin, call: verification_result)

        expect(rmi).not_to receive(:verify_pin_while)
        expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
        expect(runner).to receive(:sleep).with(3)
        expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)
        result = runner.verify_contexts { |verifier| verifier.call(context) }

        expect(result).to eq(described_class::Result.new(success?: true, error_messages: [], value: verification_result))
      end

      it 'falls back to legacy verification when coordinated action is unavailable' do
        allow(rmi).to receive(:available_actions).and_return([:verify_pin])
        allow(rmi).to receive(:coordinated_verify_pin_available?).and_return(false)
        allow(rmi).to receive(:coordinated_verify_pin_supported?).and_return(true)
        verify_pin = instance_double(Cocard::VerifyPin, call: verification_result)

        expect(rmi).not_to receive(:verify_pin_while)
        expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
        expect(runner).to receive(:sleep).with(3)
        expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)
        result = runner.verify_contexts { |verifier| verifier.call(context) }

        expect(result).to eq(described_class::Result.new(success?: true, error_messages: [], value: verification_result))
      end
    end

    describe '#verify' do
      it 'propagates a single-context coordinated verification result' do
        verify_pin = instance_double(Cocard::VerifyPin, call: verification_result)

        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
          block.call
          CardTerminals::RMI::Status.success('ok')
        end
        expect(Cocard::VerifyPin).to receive(:new)
          .with(card: card, context: context).once.and_return(verify_pin)

        expect(runner.verify(context: context)).to eq(verification_result)
      end

      it 'returns the unsupported failure result for a single context' do
        expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once
          .and_return(CardTerminals::RMI::Status.unsupported)

        result = runner.verify(context: context)

        expect(result).to eq(
          described_class::Result.new(
            success?: false,
            error_messages: ['Coordinated PIN verification is not supported by this card terminal.'],
            value: nil
          )
        )
      end
    end
  end
end
