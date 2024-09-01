##
# Query for Connectors
#
module Connectors
  class Query
    attr_reader :search_options, :query

    ##
    # possible search options:
    # * :name - string
    # * :description - string
    # * :ip - string
    # * :admin_url - string
    # * :sds_url - string
    # * :manual_update - boolean
    # * :condition - integer
    # * :soap_request_success - boolean
    # * :vpnti_online - boolean
    # * :firmware_version - string
    # * :lid - string
    # * :search - string
    # * :id - integer
    # * :limit - limit result (integer)
    #
    # please note:
    #   .joins(locations: :lid)
    # must exist in relation
    #
    def initialize(relation, search_options = {})
      @relation       = relation
      @search_options = search_options.symbolize_keys
      @limit          = 0
      @query          ||= build_query
    end

    ##
    # get all matching activities
    def all
      query
    end

    ## 
    # iterate with block 
    def find_each(&block)
      query.find_each(&block)
    end

    ##
    def include?(conn)
      query.where(id: conn.id).limit(1).any?
    end

  private
    attr_accessor :relation, :limit

    def build_query
      query = relation
      search_string = [] # for global search_option :search
      search_value  = search_options.fetch(:search, false) # for global option :search
      search_options.each do |key,value|
        case key 
        when *string_fields
          query = query.where("connectors.#{key} ILIKE ?", "%#{value}%")
        when *cast_fields
          query = query.where("CAST(connectors.#{key} AS VARCHAR) ILIKE ?", "%#{value}%")
        when *id_fields
          query = query.where(key.to_sym => value)
        when :lid
          query = query.joins(:locations).where("locations.lid ILIKE ?", "%#{value}%")
        when :description
          query = query.with_description_containing(value)
        when :condition
          query = query.where(condition: value.to_i)
        when :manual_update
          query = query.where(manual_update: to_boolean(value))
        when :soap_request_success
          query = query.where(soap_request_success: to_boolean(value))
        when :vpnti_online
          query = query.where(vpnti_online: to_boolean(value))
        when :limit
          @limit = value.to_i
        when :search
          string_fields.each do |term|
            search_string << "connectors.#{term} ILIKE :search"
          end
          cast_fields.each do |key|
            search_string << "CAST(connectors.#{key} AS VARCHAR) ILIKE :search" 
          end
        else
          raise ArgumentError, "unknown search option #{key}"
        end
      end
      if search_value
        query = query.where(search_string.join(' or '), search: "%#{search_value}%")
       end
      if limit > 0
        query.limit(limit)
      else
        # Rails.logger.debug("DEBUG:: query #{query.to_sql}")
        query
      end
    end

  private

    def cast_fields
      [ :ip ]
    end

    def string_fields
      [ :name, :admin_url, :sds_url, :serial, :firmware_version]
    end

    def id_fields
      [:id]
    end

    def to_boolean(value)
      return true if ['ja', 'true', '1', 'yes', 'on', 't'].include?(value.to_s.downcase)
      return false if ['nein', 'false', '0', 'no', 'off', 'f'].include?(value.to_s.downcase)
      return nil
    end
  end
end
