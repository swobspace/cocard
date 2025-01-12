module Cards
  # 
  # Verify PINs on all verifiable cards
  #
  class VerifyAllPinsJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!

      return unless Card.verifiable_auto.any?

      #
      # all verifiable cards
      #
      Card.verifiable_auto.each do |card|
        Cocard::VerifyAllPins.new(card: card).call
        Turbo::StreamsChannel.broadcast_refresh_later_to(:verify_pins)
        Turbo::StreamsChannel.broadcast_refresh_later_to(:home)
      end

      Turbo::StreamsChannel.broadcast_prepend_to(
        'verify_pins',
        target: 'toaster',
        partial: "shared/turbo_toast",
        locals: {status: :info, message: "VERIFY PIN für alle Karten abgeschlossen"})
      sleep 1
    end

    def max_attempts
      0
    end

  private

  end
end
