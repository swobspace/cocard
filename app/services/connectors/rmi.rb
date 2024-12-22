module Connectors
  #
  # Remote Management Interface for Connectors
  #
  class RMI
    attr_reader :connector, :rmi
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

    def call(action, params = {})
      unless rmi.available_actions.include?(action)
        return
      end
      rmi.send(action, params)
    end

  private
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
