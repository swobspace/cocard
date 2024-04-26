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
      @context = options.fetch(:context)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      result = Cocard::SOAP::GetResourceInformation.new(
                 connector: context.connector,
                 mandant: context.mandant,
                 client_system: context.client_system,
                 workplace: context.workplace).call
      unless result.success?
        return Result.new(success?: false, error_messages: result.error_messages, 
                          resource_information: nil)
      end
      resource_information = Cocard::ResourceInformation.new(result.response)

      Result.new(success?: true, error_messages: error_messages, 
                 resource_information: resource_information)
    end

  end
end
