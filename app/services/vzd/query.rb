##
# Query for VZD
#
module VZD
  class Query
    attr_reader :search_options, :connector, :client_certificate, :errors

    SEARCHES = %i( cn sn givenname displayname organization l mail telematikid 
                   entrytype personalentry domainid specialization 
                   professionoid)
    ##
    # possible search options:
    # * :sn, :givenname, :displayname, :l, :organization, :mail
    #
    #
    def initialize(connector:, client_certificate:, search_options: {})
      @errors             = []
      @limit              = 0
      @ldap               = nil
      @connector          = connector
      @client_certificate = client_certificate
      @search_options     = search_options.symbolize_keys
      @ldap_filter        = build_query

      if !@client_certificate.kind_of?(ClientCertificate)
        @errors << "Client certificate has wrong type #{@client_certificate.class.name}"
      elsif @ldap_filter.blank?
        @errors << "LDAP filter is empty or contains no valid search params"
      else
        @ldap  = ldap_connection
      end
    end

    def success?
      @errors.empty?
    end

    def query
      @query ||= Wobaduser::User.search(ldap: ldap, filter: ldap_filter)
    end

    def all
      query.nil? ? [] : query.entries
    end

    def first
      query.nil? ? nil : query.entries.first
    end

  private
    attr_reader :connector, :client_certificate, :ldap, :ldap_filter, :limit

    def tls_options
      {
        cert: client_certificate&.certificate,
        key: client_certificate&.private_key,
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
        verify_hostname: false
      }
    end

    def ldap_options 
      {
        host: connector&.ip.to_s,
        port: 636,
        base: "dc=data,dc=vzd",
        encryption: {
          method: :simple_tls,
          tls_options: tls_options
        }
      }
    end

    def ldap_connection
      Wobaduser::LDAP.new(ldap_options: ldap_options)
    end

    def build_query
      filter = []
      search_options.each do |key,value|
        case key 
        when *string_fields
          filter << "(#{key.to_s}=*#{value}*)"
        when :limit
          @limit = value.to_i
        end
      end
      
      if limit > 0
        raise RuntimeError, "Limit not yet implemented"
      end
     
      build_ldap_filter(filter)
    end

    def build_ldap_filter(filter)
      if filter.size > 1
        "(&" + filter.join('') + ")"
      else
        filter.join('')
      end
    end

    def string_fields
      SEARCHES
    end

    def to_boolean(value)
      return true if ['ja', 'true', '1', 'yes', 'on', 't'].include?(value.to_s.downcase)
      return false if ['nein', 'false', '0', 'no', 'off', 'f'].include?(value.to_s.downcase)
      return nil
    end
  end
end
