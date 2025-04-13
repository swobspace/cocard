# frozen_string_literal: true

class AcknowledgeButtonComponent < ViewComponent::Base
  # include Rails.application.routes.url_helpers
  def initialize(notable:, readonly: true, small: true)
    @notable = notable
    @readonly = readonly
    @type = :acknowledge
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
      "btn #{btn_size} btn-warning me-1"
    else
      "btn #{btn_size} btn-outline-secondary me-1"
    end
  end

  def button_action
    if @current.nil?
      new_polymorphic_path([notable, :note], type: type)
    else
      polymorphic_path([notable, current])
    end
  end

  def render?
    (!!current || !readonly) && error_state
  end

  private
  attr_reader :notable, :type, :readonly, :current, :small

  def error_state
    if notable.kind_of? Log
      true
    else
      notable.condition >= Cocard::States::WARNING
    end
  end

end
