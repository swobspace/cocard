# frozen_string_literal: true

module Workplaces
  #
  # Create or update a Workplace
  #
  class Creator
    include BooleanHelper
    attr_reader :workplace

    # creator = Workplaces::Creator(options)
    #
    # mandantory options:
    # * :attributes (hash) - attributes to process
    #
    # optional:
    # * :update_only  (boolean)
    # * :force_update (boolean)
    #
    def initialize(options = {})
      options.symbolize_keys!
      @attribs      = options.fetch(:attributes).symbolize_keys
      @name         = @attribs[:name]
      @update_only  = to_boolean(options.fetch(:update_only, true))
      @force_update = to_boolean(options.fetch(:force_update,  false))
      @workplace    = fetch_or_initialize(@attribs)
    end

    def save
      return false unless processable?
      @workplace.description = @attribs[:description]
      @workplace.save
    end

    def processable?
      # update
      if @workplace.persisted?
        force_update || @workplace.description.blank?
      # create
      else
        !update_only
      end
    end

    private
    attr_reader :update_only, :force_update

    def fetch_or_initialize(attribs)
      @workplace = Workplace.create_with(description: attribs[:description])
                            .find_or_initialize_by(name: attribs[:name])
    end

  end
end
