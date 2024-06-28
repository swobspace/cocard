module Cocard::SOAP
  #
  # Base class to be inherited by operation specific classes
  #
  class Base
    Result = ImmutableStruct.new(:success?, :error_messages, :response)

    # service = Cocard::SOAP::Base.new(options)
    #
    # mandantory options:
    # * :connector - object
    # * :mandant - string
    # * :client_system - string
    # * :workplace - string
    # optional:
    # * :iccsn - string
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :response (Hash))
    #
    def initialize(options = {})
      options.symbolize_keys
      # test for soap operation
      opera = soap_operation
      @options       = options
      @connector     = options.fetch(:connector)
      fetch_specific_options(options)
      @savon_client = init_savon_client
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      unless check_auth
        error_messages << "Missing matching client certificate for client_system: #{@client_system}"
        return Result.new(success?: false, error_messages: error_messages, response: nil)
      end

      begin
        response = @savon_client
                   .call(soap_operation,
                         attributes: soap_operation_attributes,
                         message: soap_message)
      rescue Savon::Error => error
        fault = error.to_hash[:fault]
        error_messages = [fault[:faultcode], fault[:faultstring]]
        return Result.new(success?: false, error_messages: error_messages, response: nil)
      rescue HTTPI::SSLError => error
        return Result.new(success?: false, error_messages: Array(error.message), response: nil)
      rescue Timeout::Error => error
        return Result.new(success?: false, error_messages: Array(error.message), response: nil)
      end

      Result.new(success?: true, error_messages: error_messages, response: response.body)
    end

    def soap_operation
      raise NotImplementedError, 
            "#{self.class.name} - missing operation, soap_operation is not defined"
    end

    def soap_operation_attributes
      {}
    end

  protected

    def fetch_specific_options(options)
      @mandant       = options.fetch(:mandant)
      @client_system = options.fetch(:client_system)
      @workplace     = options.fetch(:workplace)
    end

    def soap_message
      { 
        "CCTX:Context" => {
          "CONN:MandantId"      => @mandant,
          "CONN:ClientSystemId" => @client_system,
          "CONN:WorkplaceId"    => @workplace  }
      }
    end

    def init_savon_client
      globals = savon_globals
      if use_tls && use_cert
        globals  = globals.merge(savon_tls_globals)
        endpoint = endpoint_tls_location
      else
        endpoint = endpoint_location
      end
      globals = globals.merge(endpoint: endpoint)
      client = Savon.client(globals)
    end

    def savon_globals
      { 
        open_timeout: 5,
        wsdl: wsdl_content,
        env_namespace: :soapenv,
        namespace: namespace,
        namespaces: namespaces,
        convert_request_keys_to: :camelcase
      }
    end

    def savon_tls_globals
      { 
        ssl_verify_mode: :none,
        ssl_cert: auth_cert,
        ssl_cert_key: auth_pkey,
      }
    end

    def wsdl_content
      content = File.join(Rails.root, 'shared', 'wdsl', "EventService.wsdl")
    end
    
    def endpoint_location
      # "http://#{connector_ip}/service/systeminformationservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("EventService")&.endpoint_location(Cocard::EventServiceVersion)
    end

    def endpoint_tls_location
      # "http://#{connector_ip}/service/systeminformationservice"
      return nil unless @connector.kind_of? Connector
      @connector.service("EventService")&.endpoint_tls_location(Cocard::EventServiceVersion)
    end

    def namespace
      return nil unless @connector.kind_of? Connector
      # 'http://ws.gematik.de/conn/EventService/v7.2'
      # sorry, wild hack for Gematik namespace troubles, savon couldn't handle it
      @connector.service("EventService")
                &.target_namespace(Cocard::EventServiceVersion)
                &.gsub(/WSDL\//, '')
    end

    def namespaces
      {
        # "xmlns:CCTX" => "http://ws.gematik.de/conn/ConnectorContext/v2.0",
        "xmlns:CONN" => "http://ws.gematik.de/conn/ConnectorCommon/v5.0",
        "xmlns:CARDCMN" => "http://ws.gematik.de/conn/CardServiceCommon/v2.0",
       }
    end

    #
    # if authentication == clientcert : a clientcert for the use client_system
    # must be present, otherwise the soap request will be denied
    #
    def check_auth
      return true unless use_cert
      client_certificate.present?
    end

    def client_certificate
      @connector.client_certificates.where(client_system: @client_system).first
    end

    def use_tls
      @connector.use_tls
    end

    def use_cert
      @connector.authentication == 'clientcert'
    end

    def auth_cert
      client_certificate&.certificate
    end

    def auth_pkey
      client_certificate&.private_key
    end
  end
end
