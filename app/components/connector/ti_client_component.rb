# frozen_string_literal: true

class Connector::TIClientComponent < ViewComponent::Base
  def initialize(connector:, ability:)
    @connector = connector
    @ability = ability
  end

  def render?
    connector.use_ticlient?
  end

private
  attr_reader :connector, :ability
end
