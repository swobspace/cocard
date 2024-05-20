module Cocard::SOAP
  class GetCard < Base
    def soap_operation
      :get_resource_information
    end

    def soap_message(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
      @iccsn         = options.fetch(:iccsn)
      { 
        "CCTX:Context" => {
          "CONN:MandantId"      => @mandant,
          "CONN:ClientSystemId" => @client_system,
          "CONN:WorkplaceId"    => @workplace  },
        "CARDCMN:Iccsn" => @iccsn
      }
    end
  end
end
