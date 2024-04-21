module Cocard::SOAP
  class GetCards < Base
    def soap_operation
      :get_cards
    end

    def soap_operation_attributes
      { "mandant-wide": true }
    end
  end
end
