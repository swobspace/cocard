# frozen_string_literal: true

class HealthCheckButtonComponent < ViewComponent::Base
  def initialize(item:, variant: :normal)
    @item = item
    @variant = variant
  end

  def btn_class
    case variant
    when :small
      'btn btn-sm btn-secondary'
    when :outline
      'btn btn-outline-secondary me-1'
    else
      'btn btn-secondary me-1'
    end
  end

  private
    attr_reader :item, :variant
end
