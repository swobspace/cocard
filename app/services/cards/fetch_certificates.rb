module Cards
  #
  # Fetch all certificates from HBA or SMC-B
  #
  class FetchCertificates
    # service = Cards::FetchCertificates.new(options)
    #
    # mandantory options:
    # * :card    - object
    # optional:
    # * :context - object
    #
    def initialize(options = {})
      options.symbolize_keys
      @card          = options.fetch(:card)
      @connector     = @card.card_terminal&.connector
      @context       = options.fetch(:context) do 
                         @card.contexts.first || @connector.contexts.first
                       end
      @card_certificates = []
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
      unless @card.certable?
        error_messages << "ReadCardCertificate supports only HBA|SMC-B"
      end

      if error_messages.any?
        yield Cocard::Status.failure(error_messages.join("; "))
      else
        ['RSA', 'ECC'].each do |crypt|
          result = Cocard::SOAP::ReadCardCertificate.new(
                     card_handle: card.card_handle,
                     connector: connector,
                     mandant: context&.mandant,
                     client_system: context&.client_system,
                     workplace: context&.workplace,
                     cert_ref_list: cert_ref_list,
                     crypt: crypt,
                     user_id: 'cocard'
                   ).call
          if result.success?
            data_infos = Array(result.response.dig(:read_card_certificate_response,
                                                   :x509_data_info_list, :x509_data_info))
            # some processing
            data_infos.each do |di|
              card_certificate = Cocard::CardCertificate.new(di, crypt).save(card: card)
              @card_certificates << card_certificate if card_certificate.present?
            end
            
            yield Cocard::Status.success("Kartenzertifikate erfolgreich eingelesen", @card_certificates)
          else
            error_messages = result.error_messages
            yield Cocard::Status.failure(error_messages.join("; "))
          end
        end
      end
    end

    private
      attr_reader :connector, :context, :card

      def cert_ref_list
        card_type = card.card_type
        if card_type == 'SMC-B'
          cert_ref_list = %w( C.AUT C.ENC C.SIG )
        elsif card_type == 'HBA'
          cert_ref_list = %w( C.AUT C.ENC C.QES)
        else
          raise "Wrong card type: #{card_type}, instead of HBA|SMC-B"
        end
      end

  end
end
