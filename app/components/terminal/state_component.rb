# frozen_string_literal: true

class Terminal::StateComponent < ViewComponent::Base
  def initialize(terminal:, attribute:)
    @terminal = terminal
    @attr     = attribute
  end

  def render?
    terminal.present? && attr.present?
  end

  def attribute_class
    case attr.to_s
    when 'connected'
      if !terminal.connected and terminal.correlation == 'AKTIV'
        'badge text-bg-danger'
      end
    when 'correlation'
    end
  end

  def text
    case attr.to_s
    when 'connected'
      boolean_text(terminal.send(attr))
    else
      terminal.send(attr)
    end
  end

private
  attr_reader :terminal, :attr

  def boolean_text(value)
    I18n.t(value)
  end
end
