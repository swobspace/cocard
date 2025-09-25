# frozen_string_literal: true

class HealthCheckButtonComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end

  private
    attr_reader :item
end
