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
    # * :last_seen - timestamp
    # * :message   - text
    #
    def initialize(options = {})
      options.symbolize_keys
      @loggable  = options.fetch(:loggable)
      @action    = options.fetch(:action)
      @level     = options.fetch(:level)
      @last_seen = options.fetch(:last_seen)
      @message   = options.fetch(:message)
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def save
      @log = Log.create_with(last_seen: @last_seen)
                .find_or_initialize_by(
                   loggable: @loggable,
                   action:   @action,
                   level:    @level,
                   message:  @message
                 )

      if @log.persisted?
        @log.update(last_seen: @last_seen)
      elsif @log.save
        true 
      else
        Rails.logger.warn("WARN:: could not update timestamp: " +
          @log.errors.full_messages.join('; '))
        false
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations
  end
end
