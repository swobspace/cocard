##
# Query for Card Terminals
#
module CardTerminals
  class Query
    attr_reader :search_options, :query

    ##
    # possible search options: see code, to much to list separately
    #
    # please note:
    #   .left_outer_joins(:location, :connector, card_terminal_slots: :card)
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
          query = query.where("card_terminals.#{key} ILIKE ?", "%#{value}%")
        when *cast_fields
          query = query.where("replace(card_terminals.#{key}::varchar, ':', '') ILIKE ?",
                              "%#{value}%")
        when *id_fields
          query = query.where(key.to_sym => value)
        when *date_fields
          query = query.where("to_char(card_terminals.#{key}, 'YYYY-MM-DD') ILIKE ?",
                              "%#{value}%")
        when :lid
          query = query.where("locations.lid ILIKE ?", "%#{value}%")
        when :description
          query = query.with_description_containing(value)
        when :condition
          if value.to_s == value.to_i.to_s
            query = query.where(condition: value.to_i)
          else
            query = query.where(condition: i18n_search(value, I18n.t('cocard.condition')))
          end
        when :tag
          query = query.joins(taggings: :tag).where("tags.name ILIKE ?", "%#{value}%")
        when :connected
          query = query.where(connected: to_boolean(value))
        when :connector
          query = query.where("connectors.name ILIKE ?", "%#{value}%")
        when :pin_mode
          query = query.where(pin_mode: i18n_search(value, I18n.t('pin_modes')))
        when :iccsn
          query = query.where("cards.card_type = ?", 'SMC-KT')
                       .where("cards.iccsn ILIKE ?", "%#{value}%")
        when :expiration_date
          query = query.where("cards.card_type = ?", 'SMC-KT')
                       .where("to_char(cards.expiration_date, 'YYYY-MM-DD') ILIKE ?",
                              "%#{value}%")
        when :outdated
          if to_boolean(value)
            query = query.where("card_terminals.last_check < ? or card_terminals.last_check IS NULL", 1.day.before(Date.current))
          else
            query = query.where("card_terminals.last_check >= ?", 1.day.before(Date.current))
          end
        when :acknowledged
          if to_boolean(value)
            query = query.acknowledged
          else
            query = query.not_acknowledged
          end
        when :with_smcb
          query = query.where("cards.card_type = 'SMC-B'")
        when :limit
          @limit = value.to_i
        when :search
          string_fields.each do |term|
            search_string << "card_terminals.#{term} ILIKE :search"
          end
          cast_fields.each do |key|
            search_string << "CAST(card_terminals.#{key} AS VARCHAR) ILIKE :search"
          end
          search_string << "replace(card_terminals.mac::varchar, ':', '') ILIKE :search"
        else
          raise ArgumentError, "unknown search option #{key}" unless Rails.env.production?
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
      [ :ip, :mac ]
    end

    def string_fields
      [ :displayname, :name, :condition_message,
        :room, :contact, :plugged_in,
        :supplier, :serial, :id_product, :idle_message,
        :ct_id, :firmware_version,
      ]
    end

    def date_fields
      [ :delivery_date, :last_ok, :last_check, :updated_at
      ]
    end

    def id_fields
      [ :id ]
    end

    def to_boolean(value)
      return true if ['ja', 'true', '1', 'yes', 'on', 't'].include?(value.to_s.downcase)
      return false if ['nein', 'false', '0', 'no', 'off', 'f'].include?(value.to_s.downcase)
      return nil
    end

    # example: i18n_search('On Demand', I18n.t('pin_mode')) => 'on_demand'
    def i18n_search(value, translation = {})
      result = []
      translation.each_pair do |k,v|
        if (v =~ /#{value}/i) || value == k.to_s
          result << ((k == :notset) ? '' : k)
        end
      end
      result
    end
  end
end
