require 'rails_helper'

module Cocard
  RSpec.describe VerifyPinWithSt1506Retry do
    let(:card) { instance_double(Card) }
    let(:context) { instance_double(Context) }
    let(:pin_verify_4060) do
      instance_double(Cocard::PinVerify, error_code: '4060', error_text: 'Ressourcenreservierung aktiv')
    end
    let(:pin_verify_rejected) do
      instance_double(Cocard::PinVerify, error_code: '4091', error_text: 'Falsche PIN')
    end
    let(:retryable_result) do
      Cocard::VerifyPin::Result.new(success?: false,
                                    error_messages: ['ERROR', '4060 Ressourcenreservierung'],
                                    pin_verify: pin_verify_4060)
    end
    let(:success_result) do
      Cocard::VerifyPin::Result.new(success?: true, error_messages: [], pin_verify: nil)
    end
    let(:rejected_result) do
      Cocard::VerifyPin::Result.new(success?: false,
                                    error_messages: ['REJECTED', 'Falsche PIN'],
                                    pin_verify: pin_verify_rejected)
    end

    subject(:service) do
      described_class.new(card: card, context: context, retries: 2, delay: 0)
    end

    before do
      allow(service).to receive(:sleep)
    end

    it 'retries connector VerifyPin for trace code 4060 and returns the final result' do
      verify_pin = instance_double(Cocard::VerifyPin)
      expect(Cocard::VerifyPin).to receive(:new)
        .with(card: card, context: context).exactly(2).times.and_return(verify_pin)
      expect(verify_pin).to receive(:call).ordered.and_return(retryable_result)
      expect(verify_pin).to receive(:call).ordered.and_return(success_result)

      expect(service.call).to eq(success_result)
      expect(service).to have_received(:sleep).once.with(0)
    end

    it 'retries connector VerifyPin for the gemSpec 4060 text "Ressource belegt" even if no code was parsed' do
      busy_result = Cocard::VerifyPin::Result.new(success?: false,
                                                  error_messages: ['Technical Error Ressource belegt'],
                                                  pin_verify: nil)
      verify_pin = instance_double(Cocard::VerifyPin)
      expect(Cocard::VerifyPin).to receive(:new)
        .with(card: card, context: context).exactly(2).times.and_return(verify_pin)
      expect(verify_pin).to receive(:call).ordered.and_return(busy_result)
      expect(verify_pin).to receive(:call).ordered.and_return(success_result)

      expect(service.call).to eq(success_result)
      expect(service).to have_received(:sleep).once.with(0)
    end

    it 'does not retry wrong PIN or other non-4060 failures' do
      verify_pin = instance_double(Cocard::VerifyPin)
      expect(Cocard::VerifyPin).to receive(:new)
        .with(card: card, context: context).once.and_return(verify_pin)
      expect(verify_pin).to receive(:call).once.and_return(rejected_result)

      expect(service.call).to eq(rejected_result)
      expect(service).not_to have_received(:sleep)
    end

    it 'returns the last 4060 result after exhausting retries' do
      verify_pin = instance_double(Cocard::VerifyPin)
      expect(Cocard::VerifyPin).to receive(:new)
        .with(card: card, context: context).exactly(3).times.and_return(verify_pin)
      expect(verify_pin).to receive(:call).exactly(3).times.and_return(retryable_result)

      expect(service.call).to eq(retryable_result)
      expect(service).to have_received(:sleep).twice.with(0)
    end
  end
end
