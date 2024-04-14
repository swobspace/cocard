module Cocard
  class ProductInformation
    def initialize(hash)
      @hash = hash || {}
    end

    def information_date
      hash['InformationDate'] || nil
    end

    def product_type_information
      hash['ProductTypeInformation'] || {}
    end

    def product_identification
      hash['ProductIdentification'] || {}
    end

    def product_miscellaneous
      hash['ProductMiscellaneous'] || {}
    end

    def to_s
      text = <<~TOTEXT
        ProduktTypeInformation:
          ProductType: #{product_type_information['ProductType']}
          ProductTypeVersion: #{product_type_information['ProductTypeVersion']}

        ProductIdentification:
          ProductVendorID: #{product_identification['ProductVendorID']}
          ProductCode: #{product_identification['ProductCode']}
          ProductVersion:
            Local:
              HWVersion: #{product_identification['ProductVersion']['Local']['HWVersion']}
              FWVersion: #{product_identification['ProductVersion']['Local']['FWVersion']}

        ProductMiscellaneous:
          ProductVendorName: #{product_miscellaneous['ProductVendorName']}
          ProductName: #{product_miscellaneous['ProductName']}

        #{information_date}
      TOTEXT
    end

  private
    attr_reader :hash
  end
end
