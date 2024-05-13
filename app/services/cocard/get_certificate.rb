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
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :cards (Array))
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector_context = options.fetch(:connector_context)
      @connector     = @connector_context.connector
      @mandant       = @connector_context.context.mandant
      @client_system = @connector_context.context.client_system
      @workplace     = @connector_context.context.workplace
      @card          = options.fetch(:card)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      result = Cocard::SOAP::ReadCardCertificate.new(
                 card_handle: card.card_handle,
                 connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace).call
      if result.success?
        rawcert = result.response[:read_card_certificate_response][:x509_data_info_list][:x509_data_info][:x509_data][:x509_certificate]
        cert = Cocard::Certificate.new(rawcert)
        # card.update(...)


        Result.new(success?: true, error_messages: error_messages, 
                   certificate: cert)
      else
        Result.new(success?: false, error_messages: result.error_messages, 
                   certificate: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system, :card
  end
end
