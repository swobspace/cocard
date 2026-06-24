module Cocard
  # Retry connector VerifyPin only for the ST1506 coordinated flow when the
  # connector reports resource reservation (trace code 4060).
  class VerifyPinWithSt1506Retry
    DEFAULT_RETRIES = 2
    DEFAULT_DELAY = 3.seconds
    RESOURCE_RESERVATION_CODE = '4060'
    RESOURCE_RESERVATION_TEXT = /resource.?reservation|ressourcenreservierung|reservier|ressource[n]?\s+belegt/i

    def initialize(options = {})
      options = options.symbolize_keys
      @card = options.fetch(:card)
      @context = options.fetch(:context)
      @retries = options.fetch(:retries, DEFAULT_RETRIES)
      @delay = options.fetch(:delay, DEFAULT_DELAY)
    end

    def call
      attempts = 0

      loop do
        result = Cocard::VerifyPin.new(card: card, context: context).call
        return result unless retryable_resource_reservation?(result)
        return result if attempts >= retries

        attempts += 1
        sleep delay
      end
    end

  private
    attr_reader :card, :context, :retries, :delay

    def retryable_resource_reservation?(result)
      return false if result.blank? || result.success?

      pin_verify = result.respond_to?(:pin_verify) ? result.pin_verify : nil
      error_code = pin_verify.respond_to?(:error_code) ? pin_verify.error_code.to_s : nil
      return true if error_code == RESOURCE_RESERVATION_CODE

      messages = Array(result.respond_to?(:error_messages) ? result.error_messages : nil)
      messages << pin_verify.error_text if pin_verify.respond_to?(:error_text)
      messages.compact.any? do |message|
        text = message.to_s
        text.include?(RESOURCE_RESERVATION_CODE) || text.match?(RESOURCE_RESERVATION_TEXT)
      end
    end
  end
end
