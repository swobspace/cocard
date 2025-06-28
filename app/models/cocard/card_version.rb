module Cocard
  class CardVersion

    ATTRIBUTES = %i( cos_version object_system_version atr_version gdo_version)

    def initialize(hash)
      @hash = hash || {}
    end

    def card_version
      hash
    end

    ATTRIBUTES.each do |attrib|
      define_method(attrib) do
        specific_card_version(attrib)
      end
    end

  private
    attr_reader :hash

    def specific_card_version(attribute)
      return nil unless card_version.present?
      build_version(card_version[attribute.to_sym])
    end

    def build_version(hash)
      [hash[:major], hash[:minor], hash[:revision]].join('.')
    end
  end
end
