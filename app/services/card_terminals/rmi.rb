module CardTerminals
  #
  # Remote Management Interface for CardTerminals
  #
  class RMI
    attr_reader :card_terminal, :rmi
    #
    # rmi = CardTerminals::RMI.new(options)
    #
    # mandantory options:
    # * :card_terminal - object
    #
    def initialize(options = {})
      options    = options.symbolize_keys
      @card_terminal = options.fetch(:card_terminal)
      @rmi       = set_rmi
    end

    def available_actions 
      rmi.available_actions
    end

    def rmi_port
      rmi.rmi_port
    end

    def call(action, params = {})
      unless rmi.available_actions.include?(action)
        return
      end
      rmi.send(action, params)
      rmi.result
    end

  private
    def set_rmi
      case card_terminal.identification
      when 'INGHC-ORGA6100'
        CardTerminals::RMI::OrgaV1.new(card_terminal: card_terminal)
      else
        CardTerminals::RMI::Null.new(card_terminal: card_terminal)
      end
    end

  end
end
