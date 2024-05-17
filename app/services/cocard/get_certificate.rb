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
      @context       = options.fetch(:context)
      @connector     = @card.card_terminal&.connector
      @mandant       = @context.mandant
      @client_system = @context.client_system
      @workplace     = @context.workplace
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

      result = Cocard::SOAP::ReadCardCertificate.new(
                 card_handle: card.card_handle,
                 connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace).call
      if error_messages.blank? and result.success?
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
          return Result.new(success?: true, error_messages: error_messages, 
                            certificate: cert)
        else
          error_messages << card.errors&.full_messages
        end
      end
      Result.new(success?: false, error_messages: result.error_messages, 
                 certificate: nil)
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system, :card
  end
end
