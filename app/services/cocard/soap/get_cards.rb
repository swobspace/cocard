module Cocard::SOAP
  class GetCards < Base
    def soap_operation
      :get_cards
    end

    def fetch_specific_options(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
      @ct_id         = options.fetch(:ct_id, nil)
    end

    def soap_message
      {
        "CCTX:Context" => {
          "CONN:MandantId"      => @mandant,
          "CONN:ClientSystemId" => @client_system,
          "CONN:WorkplaceId"    => @workplace  }
      }.merge(soap_addons)
    end

    def soap_addons
      if @ct_id
        { "CARDCMN:CtId" => @ct_id }
      else
        { }
      end
    end

    def soap_operation_attributes
      { "mandant-wide": mandant_wide }
    end

    def mandant_wide
      if @ct_id.present?
        false
      else
        @mandant_wide
      end
    end
  end
end
