module Connectors
  #
  # Remote Management Interface for Connectors
  #
  class RMI
    attr_reader :connector
    #
    # rmi = Connectors::RMI.new(options)
    #
    # mandantory options:
    # * :connector - object
    #
    def initialize(options = {})
      options    = options.symbolize_keys
      @connector = options.fetch(:connector)
      @rmi       = set_rmi
    end

    def available_actions 
      rmi.available_actions
    end

    def supported?
      rmi.supported?
    end

    def reboot
      if supported? && available_actions.include?(:reboot)
        result = rmi.reboot
        if result.success?
          yield Status.success(result.message)
        else
          yield Status.failure(result.message)
        end
      else
        yield Status.unsupported
      end
    end

  private
    attr_reader :rmi

    def set_rmi
      case connector.identification
      when 'KOCOC-kocobox'
        Connectors::RMI::Kocobox.new(connector: connector)
      else
        Connectors::RMI::Null.new(connector: connector)
      end
    end

  end
end
