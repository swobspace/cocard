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
      @connector_context = options.fetch(:connector_context)
      @connector = @connector_context.connector
      @mandant   = @connector_context.context.mandant
      @client_system  = @connector_context.context.client_system
      @workplace = @connector_context.context.workplace
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      result = Cocard::SOAP::GetResourceInformation.new(
                 connector: connector,
                 mandant: mandant,
                 client_system: client_system,
                 workplace: workplace).call
      unless result.success?
        return Result.new(success?: false, error_messages: result.error_messages, 
                          resource_information: nil)
      end
      resource_information = Cocard::ResourceInformation.new(result.response)

      Result.new(success?: true, error_messages: error_messages, 
                 resource_information: resource_information)
    end

  private
    attr_reader :connector, :context, :workplace, :mandant, :client_system
  end
end
