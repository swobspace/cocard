module Cocard
  #
  # Get resource information from connektor
  #
  class GetCertificate
    Result = ImmutableStruct.new(:success?, :error_messages, :certificate)

    # service = Cocard::GetCertificate.new(options)
    #
    # mandantory options:
    # * :context - object
    # * :card    - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :cards (Array))
    #
    def initialize(options = {})
      options.symbolize_keys
      @card          = options.fetch(:card)
      @context       = options.fetch(:context) { @card.contexts.first }
      @connector     = @card.card_terminal&.connector
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      if @card.card_handle.blank?
        error_messages << "No Card Handle available!"
      end
      if @connector.blank?
        error_messages << "No Connector assigned!"
      end
      if @context.blank?
        error_messages << "No Context assigned!"
      end
      if error_messages.any?
        return Result.new(success?: false, error_messages: error_messages, 
                          certificate: nil)
      end

      result = Cocard::SOAP::ReadCardCertificate.new(
                 card_handle: card.card_handle,
                 connector: connector,
                 mandant: context&.mandant,
                 client_system: context&.client_system,
                 workplace: context&.workplace).call
      if result.error_messages.blank? and result.success?
        rawcert = result.response[:read_card_certificate_response][:x509_data_info_list][:x509_data_info][:x509_data][:x509_certificate]
        cert = Cocard::Certificate.new(rawcert)
        card.name = cert.cn if card.name.blank?
        card.cert_subject_cn = cert.cn
        card.cert_subject_title = cert.title
        card.cert_subject_sn = cert.sn
        card.cert_subject_givenname = cert.givenname
        card.cert_subject_street = cert.street
        card.cert_subject_postalcode = cert.postalcode
        card.cert_subject_l = cert.l
        card.cert_subject_o = cert.o
        card.bsnr = cert.o if card.bsnr.blank?
        card.telematikid = cert.telematikid
        card.certificate = rawcert

        if card.save
          log_error(nil)
          return Result.new(success?: true, error_messages: error_messages, 
                            certificate: cert)
        else
          error_messages << card.errors&.full_messages
        end
      else
        error_messages = result.error_messages
      end

      log_error(error_messages)
      Result.new(success?: false, error_messages: result.error_messages, 
                 certificate: nil)
    end

  private
    attr_reader :connector, :context, :card

    def log_error(message)
      logger = Logs::Creator.new(loggable: card, level: 'ERROR',
                                 action: 'GetCertificate', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: GetCertificate - #{message}")
      end
    end

  end
end
