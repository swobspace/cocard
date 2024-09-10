# frozen_string_literal: true

class AcknowledgeButtonComponent < ViewComponent::Base
  # include Rails.application.routes.url_helpers
  def initialize(notable:, readonly: true, small: true)
    @notable = notable
    @readonly = readonly
    @type = Note.types[:acknowledge]
    @current = notable.current_acknowledge
    @small = small
  end

  def btn_size
    if small
      "btn-sm"
    else
      "btn"
    end
  end

  def button_css
    if @current.nil?
      "btn #{btn_size} btn-warning"
    else
      "btn #{btn_size} btn-outline-secondary"
    end
  end

  def button_action
    if @current.nil?
      new_log_note_path(notable, type: type)
    else
      log_note_path(notable, current)
    end
  end

  def render?
    !!current || !readonly
  end

  private
  attr_reader :notable, :type, :readonly, :current, :small

end
