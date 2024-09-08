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
      @since     = options.fetch(:since) { Time.current }
      @message   = Array(options.fetch(:message)).join("; ")
      @is_valid  = options.fetch(:is_valid) { true }
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def call(destroy = false)
      @log = Log.find_or_initialize_by(loggable: @loggable, 
                                       action: @action,
                                       level: @level) do |l|
                l.last_seen = @last_seen
                l.since     = @since
                l.message   = @message 
                l.is_valid  = @is_valid
              end

      if @log.persisted?
        if destroy == false
          if @log.is_valid
            # update, don't touch :since or :is_valid
            # update always acknowledge, present ack may be expired
            attrs = { last_seen: @last_seen, message: @message,
                      acknowledge_id: current_ackid }
          else
            # switch from invalid to valid => update :since
            attrs = { last_seen: @last_seen, message: @message,
                      is_valid: true, since: @since }
          end
          @log.update(attrs)
        else
          # mark as invalid instead of destroy
          # and terminate all open acknowledgements
          @log.acknowledges.active.update_all(valid_until: (Time.current - 1.minute))
          @log.update(is_valid: false, acknowledge_id: nil)
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

  private
    def current_ackid
      @log.current_acknowledge&.id
    end
    
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations
  end
end
