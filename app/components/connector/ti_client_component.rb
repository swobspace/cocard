# frozen_string_literal: true

class Connector::TIClientComponent < ViewComponent::Base
  def initialize(connector:, readonly:)
    @connector = connector
    @readonly = readonly
  end

  def render?
    connector.use_ticlient?
  end

private
  attr_reader :connector, :readonly
end
