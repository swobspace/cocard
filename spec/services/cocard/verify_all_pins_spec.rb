require 'rails_helper'

RSpec.describe Cocard::VerifyAllPins do
  let(:card) { instance_double(Card, card_terminal: terminal, contexts: contexts, iccsn: '80276883110000123456', name: 'SMC-B', to_s: 'SMC-B') }
  let(:terminal) { instance_double(CardTerminal, pin_mode: 'on', rmi: rmi) }
  let(:rmi) do
    instance_double(CardTerminals::RMI,
                    coordinated_verify_pin_available?: true,
                    coordinated_verify_pin_supported?: true)
  end
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
    allow_any_instance_of(Cocard::PinVerificationRunner).to receive(:sleep)
  end

  it 'uses coordinated PIN verification inside one verify_pin_while block' do
    verify_pin = instance_double(Cocard::VerifyPin, call: verify_result)
    expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
      block.call
      CardTerminals::RMI::Status.success('ok')
    end
    expect(Cocard::VerifyPin).to receive(:new)
      .with(card: card, context: context).once.and_return(verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).to be_success
    expect(result.error_messages).to eq([])
  end

  it 'keeps one coordinated listener around multiple per-context VerifyPin calls' do
    other_context = instance_double(Context, to_s: 'Anderer Kontext')
    allow(contexts).to receive(:each).and_yield(context).and_yield(other_context)
    first_verify_pin = instance_double(Cocard::VerifyPin, call: verify_result)
    second_verify_pin = instance_double(Cocard::VerifyPin, call: verify_result)

    expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
      block.call
      CardTerminals::RMI::Status.success('ok')
    end
    expect(Cocard::VerifyPin).to receive(:new)
      .with(card: card, context: context).once.and_return(first_verify_pin)
    expect(Cocard::VerifyPin).to receive(:new)
      .with(card: card, context: other_context).once.and_return(second_verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).to be_success
    expect(result.error_messages).to eq([])
  end

  it 'aggregates coordinated verification failures from a successful verify_pin_while block' do
    failed_verify_result = Cocard::VerifyPin::Result.new(success?: false, error_messages: ['verify failed'], pin_verify: nil)
    verify_pin = instance_double(Cocard::VerifyPin, call: failed_verify_result)
    expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
      block.call
      CardTerminals::RMI::Status.success('ok')
    end
    expect(Cocard::VerifyPin).to receive(:new)
      .with(card: card, context: context).once.and_return(verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).not_to be_success
    expect(result.error_messages).to eq(['verify failed'])
    expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
      .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
  end

  it 'aggregates distinct failures from multiple coordinated contexts' do
    other_context = instance_double(Context, to_s: 'Anderer Kontext')
    allow(contexts).to receive(:each).and_yield(context).and_yield(other_context)
    first_failed_result = Cocard::VerifyPin::Result.new(success?: false, error_messages: ['first verify failed'], pin_verify: nil)
    second_failed_result = Cocard::VerifyPin::Result.new(success?: false, error_messages: ['second verify failed'], pin_verify: nil)
    first_verify_pin = instance_double(Cocard::VerifyPin, call: first_failed_result)
    second_verify_pin = instance_double(Cocard::VerifyPin, call: second_failed_result)

    expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once do |_iccsn, &block|
      block.call
      CardTerminals::RMI::Status.success('ok')
    end
    expect(Cocard::VerifyPin).to receive(:new)
      .with(card: card, context: context).once.and_return(first_verify_pin)
    expect(Cocard::VerifyPin).to receive(:new)
      .with(card: card, context: other_context).once.and_return(second_verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).not_to be_success
    expect(result.error_messages).to eq(['first verify failed', 'second verify failed'])
    expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
      .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
      .twice
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

  it 'returns a failure result and broadcasts an alert when coordinated RMI fails' do
    expect(rmi).to receive(:verify_pin_while).with(card.iccsn).once
      .and_return(CardTerminals::RMI::Status.failure('coordinated verification failed'))

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).not_to be_success
    expect(result.error_messages).to eq(['coordinated verification failed'])
    expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
      .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
  end

  it 'keeps legacy unsupported behavior on the direct VerifyPin path' do
    allow(rmi).to receive(:coordinated_verify_pin_available?).and_return(false)
    allow(rmi).to receive(:coordinated_verify_pin_supported?).and_return(false)
    verify_pin = instance_double(Cocard::VerifyPin, call: verify_result)
    expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
    expect_any_instance_of(Cocard::PinVerificationRunner).to receive(:sleep).with(3).once
    expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).to be_success
    expect(result.error_messages).to eq([])
  end

  it 'keeps ORGA-shaped RMI with verify_pin action on the legacy VerifyPin path' do
    allow(rmi).to receive(:coordinated_verify_pin_available?).and_return(false)
    allow(rmi).to receive(:coordinated_verify_pin_supported?).and_return(false)
    verify_pin = instance_double(Cocard::VerifyPin, call: verify_result)
    expect(rmi).not_to receive(:verify_pin_while)
    expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
    expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).to be_success
    expect(result.error_messages).to eq([])
  end

  it 'aggregates legacy direct VerifyPin failures' do
    allow(rmi).to receive(:coordinated_verify_pin_available?).and_return(false)
    allow(rmi).to receive(:coordinated_verify_pin_supported?).and_return(false)
    failed_verify_result = Cocard::VerifyPin::Result.new(success?: false, error_messages: ['legacy verify failed'], pin_verify: nil)
    verify_pin = instance_double(Cocard::VerifyPin, call: failed_verify_result)
    expect(CardTerminals::RMI::VerifyPinJob).to receive(:perform_later).with(card: card)
    expect(Cocard::VerifyPin).to receive(:new).with(card: card, context: context).once.and_return(verify_pin)

    result = described_class.new(card: card).call

    expect(result).to be_a(described_class::Result)
    expect(result).not_to be_success
    expect(result.error_messages).to eq(['legacy verify failed'])
    expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
      .with('verify_pins', target: 'toaster', partial: 'shared/turbo_toast', locals: hash_including(status: :alert))
  end
end
