##
# Query for Cards
#
module Cards
  class Query
    attr_reader :search_options, :query

    ##
    # possible search options:
    # * :name - string
    # * :description - string
    # * :ip - string
    # * :condition - integer
    # * :lid - string
    # * :search - string
    # * :id - integer
    # * :limit - limit result (integer)
    #
    # please note:
    #   .left_outer_joins(:location, :operational_state)
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
          query = query.where("cards.#{key} ILIKE ?", "%#{value}%")
        when *cast_fields
          query = query.where("CAST(cards.#{key} AS VARCHAR) ILIKE ?", "%#{value}%")
        when *id_fields
          query = query.where(key.to_sym => value)
        when :lid
          query = query.where("locations.lid ILIKE ?", "%#{value}%")
        when :operational_state
          query = query.where("operational_states.name ILIKE ?", "%#{value}%")
        when :operational
          if to_boolean(value)
            query = query.where("operational_states.operational = ?", true) 
          else
            query = query.where("cards.operational_state_id IS NULL or operational_states.operational = ?", false) 
          end
        when :acknowledged
          if to_boolean(value)
            query = query.acknowledged
          else
            query = query.not_acknowledged
          end
        when :description
          query = query.with_description_containing(value)
        when :condition
          query = query.where(condition: value.to_i)
        when :slotid
          query = query.where(slotid: value.to_i)
        when :expired
          if to_boolean(value)
            query = query.where("cards.expiration_date < ?", Date.current)
          else
            query = query.where("cards.expiration_date >= ?", Date.current)
          end
        when :outdated
          if to_boolean(value)
            query = query.where("cards.updated_at < ?", 1.day.before(Date.current))
          else
            query = query.where("cards.updated_at >= ?", 1.day.before(Date.current))
          end
        when :deleted
          if to_boolean(value)
            query = query.unscope(where: :deleted_at).where.not(deleted_at: nil)
          end
        when :limit
          @limit = value.to_i
        when :search
          string_fields.each do |term|
            search_string << "cards.#{term} ILIKE :search"
          end
          cast_fields.each do |key|
            search_string << "CAST(cards.#{key} AS VARCHAR) ILIKE :search" 
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
      [ ]
    end

    def string_fields
      [ :name, :lanr, :fachrichtung, :bsnr, :telematikid, :card_handle, :card_type,
        :iccsn, :card_holder_name,
        :cert_subject_cn, :cert_subject_title,
        :cert_subject_sn, :cert_subject_givenname, :cert_subject_street,
        :cert_subject_postalcode, :cert_subject_l, :cert_subject_o ]
    end

    def id_fields
      [ :id ]
    end

    def to_boolean(value)
      return true if ['ja', 'true', '1', 'yes', 'on', 't'].include?(value.to_s.downcase)
      return false if ['nein', 'false', '0', 'no', 'off', 'f'].include?(value.to_s.downcase)
      return nil
    end
  end
end
