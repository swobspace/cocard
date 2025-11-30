module Cocard
  #
  # Get resource information from connektor
  #
  class GetResourceInformation
    Result = ImmutableStruct.new(:success?, :error_messages, :resource_information)

    # service = Cocard::GetResourceInformation.new(options)
    #
    # mandantory options:
    # * :context - object
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :resource_information (Object))
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector = options.fetch(:connector)
      @context = options.fetch(:context)
      @mandant   = @context.mandant
      @client_system  = @context.client_system
      @workplace = @context.workplace
      @ct_id = options.fetch(:ct_id, nil)
      @slotid = options.fetch(:slotid, nil)
      @iccsn = options.fetch(:iccsn, nil)
    end

    # service.call()
    # do all the work here ;-)
    def call
      connector.touch(:last_check)
      error_messages = []
      params = { connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace }
      if @ct_id
        params.merge!(ct_id: @ct_id)
      end
      if @slotid
        params.merge!(slotid: @slotid)
      end
      if @iccsn
        params.merge!(ct_id: @iccsn)
      end
      result = Cocard::SOAP::GetResourceInformation.new(params).call
      if result.success?
        resource_information = Cocard::ResourceInformation.new(result.response[:get_resource_information_response])
        connector.soap_request_success = true
        connector.vpnti_online = resource_information.vpnti_online
        # connector.update_condition
        log_error_states(resource_information.error_states)
        if connector.save
          log_error(nil)
          Result.new(success?: true, error_messages: error_messages,
                     resource_information: resource_information)
        else
          error_messages = err_prefix(1) + connector.errors&.full_messages
          log_error(error_messages)
          Result.new(success?: false, error_messages: error_messages,
                     resource_information: resource_information)
        end
      else
        connector.update(soap_request_success: false)
        log_error(result.error_messages)
        Result.new(success?: false, error_messages: err_prefix(2) + result.error_messages,
                   resource_information: nil)
      end
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system

    def log_error(message)
      logger = Logs::Creator.new(loggable: connector, level: 'ERROR',
                                 action: 'GetResourceInformation', message: message)
      unless logger.call(message.blank?)
        message = Array(message).join('; ')
        Rails.logger.error("could not create log entry: GetResourceInformation - #{message}")
      end
    end

    def log_error_states(error_states)
      error_states.each do |es|
        next if filter_error_states(es)
        logger = Logs::Creator.new(loggable: connector,
                                   level: es.severity,
                                   action: es.error_condition,
                                   message: "OPERATIONAL_STATE / #{es.error_condition}")
        logger.call(!es.valid?)
      end
    end

    def filter_error_states(es)
      regex = Regexp.new(/EC_(CardTerminal|OTHER|CRYPTO|LOG_OVERFLOW)/)
      !!(regex =~ es.error_condition)
    end

    def err_prefix(step)
      ["Cocard::GetResourceInformation: /#{connector}/ #{context}: "]
    end
  end
end
