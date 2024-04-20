module Cocard::SOAP
  class GetCardTerminals < Base
    def soap_operation
      :get_card_terminals
    end

    def soap_operation_attributes
      { "mandant-wide": true }
    end
  end
end
