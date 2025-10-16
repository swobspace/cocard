##
# Query for KTProxy
#
module KTProxies
  class Query
    attr_reader :search_options, :query

    ##
    # possible search options:
    # * :name - string
    # * :ip - string
    # * :id - integer
    # * :card_terminal_id - integer
    # * :port - integer
    # * :search - string
    # * :limit - limit result (integer)
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
          query = query.where("kt_proxies.#{key} ILIKE ?", "%#{value}%")
        when *cast_fields
          query = query.where("CAST(kt_proxies.#{key} AS VARCHAR) ILIKE ?", "%#{value}%")
        when *id_fields
          query = query.where(key.to_sym => value)
        when :port
          query = query.where("kt_proxies.outgoing_port = :port OR " +
                              "kt_proxies.incoming_port = :port", 
                               port: value.to_i)
        when :limit
          @limit = value.to_i
        when :search
          search_string << "kt_proxies.incoming_port = :isearch"
          search_string << "kt_proxies.outgoing_port = :isearch"
          string_fields.each do |term|
            search_string << "kt_proxies.#{term} ILIKE :search"
          end
          cast_fields.each do |key|
            search_string << "CAST(kt_proxies.#{key} AS VARCHAR) ILIKE :search" 
          end
        else
          query = query.none
        end
      end
      if search_value
        query = query.where(search_string.join(' or '), 
                            search: "%#{search_value}%",
                            isearch: search_value.to_i)
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
      [ ]
    end

    def string_fields
      [ :name, :uuid ]
    end

    def id_fields
      [ :id, :card_terminal_id ]
    end

    def to_boolean(value)
      return true if ['ja', 'true', '1', 'yes', 'on', 't'].include?(value.to_s.downcase)
      return false if ['nein', 'false', '0', 'no', 'off', 'f'].include?(value.to_s.downcase)
      return nil
    end
  end
end
