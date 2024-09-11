# frozen_string_literal: true

module Notes
  #
  # Create or update a log entry
  #
  class Processor
    attr_reader :note

    # Notes::Processor(options)
    #
    # mandantory options:
    # * :note  - object
    #
    def initialize(options = {})
      options.symbolize_keys
      @note  = options.fetch(:note)
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def call(action)
      case action
      when :create, :update, :destroy
        if is_acknowledge
          notable.update_column(:acknowledge_id, current_ackid)
        end
      else
        raise RuntimeError, "Notes::Processor#call(#{action}) not yet implemented"
      end
    end

  private
    def notable
      note.notable
    end

    def is_acknowledge
      note.type == 'acknowledge'
    end

    def current_ackid
      note.notable&.current_acknowledge&.id
    end
    
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations
  end
end
