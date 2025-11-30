module Cocard::SOAP
  class GetResourceInformation < Base
    def soap_operation
      :get_resource_information
    end

    def fetch_specific_options(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
      @ct_id         = options.fetch(:ct_id, nil)
      @slotid        = options.fetch(:slotid, nil)
      @iccsn         = options.fetch(:iccsn, nil)
    end

    def soap_message
      soap_msg =  {
                    "CCTX:Context" => {
                    "CONN:MandantId"      => @mandant,
                    "CONN:ClientSystemId" => @client_system,
                    "CONN:WorkplaceId"    => @workplace }
                  }
      if @ct_id.present?
        soap_msg.merge!("CARDCMN:CtId" => @ct_id)
      end
      if @slotid.present?
        soap_msg.merge!("CARDCMN:SlotId" => @slotid)
      end
      if @iccsn.present?
        soap_msg.merge!("CARDCMN:Iccsn" => @iccsn)
      end

      soap_msg
    end

  end
end
