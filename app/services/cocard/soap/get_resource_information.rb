module Cocard::SOAP
  class GetResourceInformation < Base
    def soap_operation
      :get_resource_information
    end
  end
end
