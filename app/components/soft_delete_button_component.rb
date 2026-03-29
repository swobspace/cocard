# frozen_string_literal: true

class SoftDeleteButtonComponent < ViewComponent::Base
  def initialize(poly:)
    @poly = Array(poly)
  end

  def soft_deleted?
    obj.deleted_at.present?
  end

  def render?
    obj.respond_to?(:deleted_at)
  end

  private
  attr_reader :poly

  def obj
    @poly[-1]
  end
end
