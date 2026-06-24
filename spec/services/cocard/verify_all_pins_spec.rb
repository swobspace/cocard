require 'rails_helper'

module Cocard
  RSpec.describe VerifyAllPins do
    let(:card) { instance_double(Card, card_terminal: terminal, contexts: contexts, iccsn: '80276883110000123456', name: 'SMC-B', to_s: 'SMC-B') }
    let(:terminal) { instance_double(CardTerminal, pin_mode: 'on', rmi: rmi) }
    let(:rmi) { instance_double(CardTerminals::RMI, supported?: true, available_actions: [:verify_pin_while]) }
    let(:contexts) { double('contexts') }
    let(:context) { instance_double(Context, to_s: 'Kontext') }
    let(:get_card) { instance_double(Cocard::GetCard, call: Cocard::GetCard::Result.new(success?: true, error_messages: [], card: card)) }
    let(:verify_result) { Cocard::VerifyPin::Result.new(success?: true, error_messages: [], pin_verify: nil) }

    before do
      allow(contexts).to receive(:first).and_return(context)
      allow(contexts).to receive(:where).and_return(contexts)
      allow(contexts).to receive(:each).and_yield(context)
      allow(Cocard::GetCard).to receive(:new).with(card: card, context: context).and_return(get_card)
      allow(Cocard::GetPinStatus).to receive(:new).and_return(instance_double(Cocard::GetPinStatus, call: nil))
      allow(Turbo::StreamsChannel).to receive(:broadcast_prepend_to)
      allow_any_instance_of(described_class).to receive(:sleep)
    end

    it 'uses the ST1506 retry helper inside one verify_pin_while block' do
      helper = instance_double(Cocard::VerifyPinWithSt1506Retry, call: verify_result)
      expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
        block.call
        CardTerminals::RMI::Status.success('ok')
      end
      expect(Cocard::VerifyPinWithSt1506Retry).to receive(:new)
        .with(card: card, context: context).once.and_return(helper)
      expect(Cocard::VerifyPin).not_to receive(:new)

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).to be_success
      expect(result.error_messages).to eq([])
    end

    it 'aggregates ST1506 helper failures from a successful verify_pin_while block' do
      failed_verify_result = Cocard::VerifyPin::Result.new(success?: false, error_messages: ['verify failed'], pin_verify: nil)
      helper = instance_double(Cocard::VerifyPinWithSt1506Retry, call: failed_verify_result)
      expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
        block.call
        CardTerminals::RMI::Status.success('ok')
      end
      expect(Cocard::VerifyPinWithSt1506Retry).to receive(:new)
        .with(card: card, context: context).once.and_return(helper)

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).not_to be_success
      expect(result.error_messages).to eq(['verify failed'])
      expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
        .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
    end

    it 'returns a failure result and broadcasts an alert when terminal pin mode is off' do
      allow(terminal).to receive(:pin_mode).and_return('off')
      expect(Cocard::GetCard).not_to receive(:new)

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).not_to be_success
      expect(result.error_messages).to eq(["SMC-B Auto-PIN-Mode am Kartenterminal ist off!"])
      expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
        .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
    end

    it 'returns a failure result and broadcasts the existing alert when GetCard fails' do
      allow(get_card).to receive(:call).and_return(
        Cocard::GetCard::Result.new(success?: false, error_messages: ['get card failed'], card: nil)
      )

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).not_to be_success
      expect(result.error_messages).to eq(['get card failed'])
      expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
        .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
    end

    it 'returns a failure result and broadcasts an alert when coordinated ST1506 RMI fails' do
      expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once
        .and_return(CardTerminals::RMI::Status.failure('st1506 failed'))

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).not_to be_success
      expect(result.error_messages).to eq(['st1506 failed'])
      expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
        .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
    end

    it 'keeps legacy unsupported behavior on the direct VerifyPin path' do
      allow(rmi).to receive(:supported?).and_return(false)
      verify_pin = instance_double(Cocard::VerifyPin, call: verify_result)
      expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
      expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)
      expect(Cocard::VerifyPinWithSt1506Retry).not_to receive(:new)

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).to be_success
      expect(result.error_messages).to eq([])
    end

    it 'aggregates legacy direct VerifyPin failures' do
      allow(rmi).to receive(:supported?).and_return(false)
      failed_verify_result = Cocard::VerifyPin::Result.new(success?: false, error_messages: ['legacy verify failed'], pin_verify: nil)
      verify_pin = instance_double(Cocard::VerifyPin, call: failed_verify_result)
      expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
      expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)
      expect(Cocard::VerifyPinWithSt1506Retry).not_to receive(:new)

      result = described_class.new(card: card).call

      expect(result).to be_a(described_class::Result)
      expect(result).not_to be_success
      expect(result.error_messages).to eq(['legacy verify failed'])
      expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
        .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
    end
  end
end
