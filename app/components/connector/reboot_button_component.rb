# frozen_string_literal: true

class Connector::RebootButtonComponent < ViewComponent::Base
  def initialize(connector:)
    @connector = connector
  end

  def render?
    @connector.rebootable?
  end

private
  attr_reader :connector
end
