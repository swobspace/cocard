module Cocard
  #
  # Get resource information from connektor
  #
  class CheckCertificateExpiration
    Result = ImmutableStruct.new(:success?, :error_messages, :cards)

    # service = Cocard::CheckCertificateExpiration
    #
    # mandantory options:
    # * :connector - object
    # * :context - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :cards (Array))
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector = options.fetch(:connector)
      @context = options.fetch(:context)
      @mandant   = @context&.mandant
      @client_system  = @context&.client_system
      @workplace = @context&.workplace
    end

    # service.call()
    # do all the work here ;-)
    def call
      connector.touch(:last_check)
      error_messages = []
      cards = []
      result = Cocard::SOAP::CheckCertificateExpiration.new(
                 connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace).call
      if result.success?
        entry = result.response.dig(:check_certificate_expiration_response, :certificate_expiration) || []
        cexps = (entry.kind_of? Hash) ? [entry] : entry
        cexps.each do |cexp|
          card = Cocard::CertificateExpiration.new(cexp)
          cards << card
          #
          # Update connector information if card.is_connector_cert
          #
          if card.is_connector_cert
            connector.expiration_date = card.expiration_date
            connector.iccsn = card.iccsn
          end
        end
        connector.update(soap_request_success: true)

        log_error(nil)
        Result.new(success?: true, error_messages: error_messages, 
                   cards: cards)
      else
        connector.update(soap_request_success: false)
        log_error(result.error_messages)
        Result.new(success?: false, error_messages: result.error_messages, 
                   cards: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system

    def log_error(message)
      logger = Logs::Creator.new(loggable: connector, level: 'ERROR',
                                 action: 'CheckCertificateExpiration', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: CheckCertificateExpiration - #{message}")
      end
    end
  end
end
