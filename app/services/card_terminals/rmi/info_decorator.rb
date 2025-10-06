module CardTerminals
  class RMI::InfoDecorator < SimpleDelegator
    attr_reader :attributes
    #
    # creates additional methods for all Info::ATTRIBUTES
    # * attribute_default
    # * ok?
    #
    def initialize(info)
      @attributes = info.class::ATTRIBUTES
      prepare_methods(@attributes)
      super(info)
    end

  private
    def prepare_methods(attributes)
      attributes.each do |attr|
        RMI::InfoDecorator.define_method("#{attr}_default".to_sym) do
          Cocard.card_terminal_defaults.fetch(attr.to_sym, nil)
        end

        #
        # OK = 0, WARNING == 1, NOTHING == -1
        #
        RMI::InfoDecorator.define_method("#{attr}_ok?".to_sym) do
          default = Cocard.card_terminal_defaults.fetch(attr.to_sym, nil)
          if default.nil?
            Cocard::States::NOTHING
          elsif default == send(attr)
            Cocard::States::OK
          else
            Cocard::States::WARNING
          end
        end

        #
        # OK = 0, WARNING == 1, NOTHING == -1
        #
        RMI::InfoDecorator.define_method("#{attr}_eq?".to_sym) do |reference|
          reference == send(attr)
        end
      end
    end
  end
end
