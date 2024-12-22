require 'active_support'
module Cocard
  class ProductInformation
    def initialize(hash)
      if hash.nil? 
        @hash = {}
      elsif hash.keys.include?(:information_date)
        @hash = hash
      else
        @hash = hash.deep_transform_keys{|key| key.underscore.to_sym } || {}
      end
    end

    def information_date
      hash[:information_date] || nil
    end

    def product_type_information
      hash[:product_type_information] || {}
    end

    def product_identification
      hash[:product_identification] || {}
    end

    def product_miscellaneous
      hash[:product_miscellaneous] || {}
    end

    def product_code
      hash.dig(:product_identification, :product_code)
    end

    def product_vendor_id
      hash.dig(:product_identification, :product_vendor_id)
    end

    def firmware_version
      begin
        product_identification[:product_version][:local][:fw_version]
      rescue
        ""
      end
    end

    def to_s
      text = <<~TOTEXT.chomp
        ProduktTypeInformation:
          ProductType: #{product_type_information[:product_type]}
          ProductTypeVersion: #{product_type_information[:product_type_version]}

        ProductIdentification:
          ProductVendorID: #{product_identification[:product_vendor_id]}
          ProductCode: #{product_identification[:product_code]}
          ProductVersion:
            Local:
              HWVersion: #{product_identification[:product_version][:local][:hw_version]}
              FWVersion: #{product_identification[:product_version][:local][:fw_version]}

        ProductMiscellaneous:
          ProductVendorName: #{product_miscellaneous[:product_vendor_name]}
          ProductName: #{product_miscellaneous[:product_name]}

        #{information_date}
      TOTEXT
    end

  private
    attr_reader :hash
  end
end
