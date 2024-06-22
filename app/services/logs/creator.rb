# frozen_string_literal: true

module Logs
  #
  # Create or update a log entry
  #
  class Creator
    attr_reader :log

    # creator = Log::Creator(options)
    #
    # mandantory options:
    # * :loggable  - object
    # * :action    - string
    # * :level     - string
    # * :message   - text or array of strings
    #
    # optional options:
    # * :last_seen - timestamp
    #
    def initialize(options = {})
      options.symbolize_keys
      @loggable  = options.fetch(:loggable)
      @action    = options.fetch(:action)
      @level     = options.fetch(:level)
      @last_seen = options.fetch(:last_seen) { Time.current }
      @message   = Array(options.fetch(:message)).join("; ")
      @is_valid  = options.fetch(:is_valid) { true }
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def call(destroy = false)
      @log = Log.create_with(last_seen: @last_seen, message: @message, is_valid: @is_valid)
                .find_or_initialize_by(
                   loggable: @loggable,
                   action:   @action,
                   level:    @level
                 )

      if @log.persisted?
        if destroy == false
          @log.update(last_seen: @last_seen, message: @message)
        else
          @log.update(is_valid: false)
        end
      elsif (!destroy) 
        if @log.save
          true
        else
          Rails.logger.warn("WARN:: Logs::Creator: could not create log entry: " +
                            @log.inspect + "; " +
                            @log.errors.full_messages.join('; '))
          false
        end
      else
         # not persistent, nothin to delete
        true
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations
  end
end
