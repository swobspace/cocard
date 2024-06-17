module Cocard
  module ProcessCard
  private
    def self.process_card(card)
      return unless card.card_type =~ /SMC-B/

      if card.certificate.blank?
        result = Cocard::GetCertificate.new(card: card).call
        unless result.success?
           msg = "WARN:: #{card}: get certificate failed\n" +
                  result.error_messages.join("\n")
          Rails.logger.warn(msg)
        end
      end

      #
      # get pin status only from SMC-B
      #
      return unless card.card_type =~ /SMC-B/

      result = Cocard::GetPinStatus.new(card: card).call
      unless result.success?
         msg = "WARN:: #{card}: get pin status failed\n" +
                result.error_messages.join("\n")
        Rails.logger.warn(msg)
      end
    end
  end
end
