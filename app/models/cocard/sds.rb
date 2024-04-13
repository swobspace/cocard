module Cocard
  class SDS
    attr_reader :xml, :hash

    def initialize(xml)
      @xml = xml
      @hash = Nori.new(strip_namespaces: true).parse(xml)
    end

    def product_information
      ProductInformation.new(hash['ConnectorServices']['ProductInformation'])
    end


  end
end
