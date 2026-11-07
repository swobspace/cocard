module Cocard
  # Coordinates PIN verification across terminal modes while keeping terminal-specific
  # listener decisions out of controllers and higher-level Cocard services.
  class PinVerificationRunner
    Result = Data.define(:success?, :error_messages, :value)

    def initialize(options = {})
      options = options.symbolize_keys
      @card = options.fetch(:card)
    end

    def verify(context:)
      verification_result = nil
      coordination_result = verify_contexts do |verifier|
        verification_result = verifier.call(context)
      end

      return coordination_result unless coordination_result.success?

      coordination_result.value || verification_result
    end

    def verify_contexts
      if coordinated_verify_pin_available?
        run_coordinated { |verifier| yield(verifier) }
      else
        run_legacy { |verifier| yield(verifier) }
      end
    end

  private
    attr_reader :card

    def run_coordinated
      block_value = nil
      rmi_status = rmi.verify_pin_while(card.iccsn) do
        block_value = yield(method(:verify_pin))
      end

      rmi_error_messages = []
      rmi_status.on_failure do |rmi_message|
        rmi_error_messages = Array(rmi_message)
      end
      rmi_status.on_unsupported do
        rmi_error_messages = ["Coordinated PIN verification is not supported by this card terminal."]
      end
      return Result.new(success?: false, error_messages: rmi_error_messages, value: nil) if rmi_error_messages.any?

      value = block_value
      rmi_status.on_success do |_message, status_value|
        value = status_value unless status_value.nil?
      end
      Result.new(success?: true, error_messages: [], value: value)
    end

    def run_legacy
      CardTerminals::RMI::VerifyPinJob.perform_later(card: card)
      sleep 3

      value = yield(method(:verify_pin))
      Result.new(success?: true, error_messages: [], value: value)
    end

    def coordinated_verify_pin_available?
      rmi&.coordinated_verify_pin_available?
    end

    def verify_pin(context)
      Cocard::VerifyPin.new(card: card, context: context).call
    end

    def rmi
      @rmi ||= card.card_terminal&.rmi
    end
  end
end
