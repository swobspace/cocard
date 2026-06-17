module CardTerminals
  #
  # Remote Management Interface for CardTerminals
  #
  class RMI
    attr_reader :card_terminal
    SUPPORTED_IDENTIFICATIONS = %w[ INGHC-ORGA6100 CHERRY-ST1506 CHERRY-ST-1506 ]
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

    def supported?
      rmi.supported?
    end

    def rmi_port
      rmi.rmi_port
    end

    def reboot
      if supported? && available_actions.include?(:reboot)
        result = rmi.reboot
        if result.success?
          yield Status.success(result.message.to_s)
        else
          yield Status.failure(result.message.to_s)
        end
      else
        yield Status.unsupported
      end
    end

    def get_info
      if supported? && available_actions.include?(:get_info)
        result = rmi.get_info
        if result.success?
          yield Status.success(result.message.to_s, result.value)
        else
          yield Status.failure(result.message.to_s)
        end
      else
        yield Status.unsupported
      end
    end

    def get_idle_message
      if supported? && available_actions.include?(:get_idle_message)
        result = rmi.get_idle_message
        if result.success?
          yield Status.success(result.message.to_s, result.value)
        else
          yield Status.failure(result.message.to_s)
        end
      else
        yield Status.unsupported
      end
    end

    def set_idle_message(message)
      if supported? && available_actions.include?(:set_idle_message)
        result = rmi.set_idle_message(message)
        if result.success?
          yield Status.success(result.message.to_s)
        else
          yield Status.failure(result.message.to_s)
        end
      else
        yield Status.unsupported
      end
    end

    def verify_pin(iccsn)
      if supported? && available_actions.include?(:verify_pin)
        result = rmi.verify_pin(iccsn)
        if result.success?
          yield Status.success(result.message.to_s)
        else
          yield Status.failure(result.message.to_s)
        end
      else
        yield Status.unsupported
      end
    end

    def remote_pairing
      timeout = 30
      if supported? && available_actions.include?(:remote_pairing)
        begin
          result = Timeout::timeout(timeout) { rmi.remote_pairing }
          if result.success?
            yield Status.success(result.message.to_s)
          else
            yield Status.failure(result.message.to_s)
          end
        rescue
          message = "Timeout nach #{timeout} sec," +
                    " Terminal antwortet nicht oder Anfrage vom Konnektor kam zu spät!"
          yield Status.failure(message)
        end
      else
        yield Status.unsupported
      end
    end

  private
    attr_reader :rmi

    def set_rmi
      case card_terminal.identification
      when 'INGHC-ORGA6100'
        CardTerminals::RMI::OrgaV1.new(card_terminal: card_terminal)
      else
        if cherry_st1506?
          CardTerminals::RMI::CherryV1.new(card_terminal: card_terminal)
        else
          CardTerminals::RMI::Null.new(card_terminal: card_terminal)
        end
      end
    end

    def cherry_st1506?
      product_miscellaneous = card_terminal.product_information&.product_miscellaneous || {}
      candidates = [
        card_terminal.identification,
        card_terminal.id_product,
        card_terminal.product_information&.product_code,
        product_miscellaneous[:product_name],
        product_miscellaneous['product_name']
      ].compact.map(&:to_s)

      candidates.any? { |candidate| candidate.match?(/ST[-_ ]?1506/i) }
    end

  end
end
