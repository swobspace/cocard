# frozen_string_literal: true

class NoteButtonComponent < ViewComponent::Base
  # include Rails.application.routes.url_helpers
  def initialize(notable:, type: Note.types[:plain])
    @notable = notable
    @type = type

    case type
    when Note.types[:plain]
      @current = notable.current_note
    when Note.types[:acknowledge]
      @current = notable.current_acknowledge
    else
      raise "NoteButtonComponent: type #{type} not implemented"
    end
  end

  def button_css
    if @current.nil?
      "btn btn-sm btn-warning"
    else
      "btn btn-sm btn-outline-secondary"
    end
  end

  def button_action
    if @current.nil?
      new_log_note_path(notable, type: type)
    else
      log_note_path(notable, current)
    end
  end

  private
  attr_reader :notable, :type, :current

end
