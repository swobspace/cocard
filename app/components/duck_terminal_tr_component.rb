# frozen_string_literal: true

class DuckTerminalTrComponent < ViewComponent::Base
  def initialize(card_terminal:, info:, attrib:)
    @card_terminal = card_terminal
    @info = info
    @attrib = attrib
    @decorated = CardTerminals::RMI::InfoDecorator.new(@info)
  end

  def color
    if @card_terminal.present? and [:macaddr, :terminalname].include?(attrib.to_sym)
      case attrib.to_sym
      when :macaddr
        (info.send(attrib) == card_terminal.mac) ? "bg-success bg-opacity-25" : "bg-danger bg-opacity-50"
      when :terminalname
        (info.send(attrib) == card_terminal.name) ? "bg-success bg-opacity-25" : "bg-danger bg-opacity-50"
      end
    else
      case @decorated.send("#{attrib}_ok?")
      when Cocard::States::NOTHING 
        ""
      when Cocard::States::OK 
        "bg-success bg-opacity-25"
      when Cocard::States::WARNING
        "bg-warning bg-opacity-50"
      when Cocard::States::CRITICAL
        "bg-danger bg-opacity-50"
      else
        "bg-info bg-opacity-25"
      end
    end
  end

private
  attr_reader :info, :attrib, :card_terminal
end
