# frozen_string_literal: true

module NotableConcerns
  extend ActiveSupport::Concern

  included do
    has_many :acknowledges, -> { where(type: types[:acknowledge]) },
             as: :notable, class_name: 'Note'
  end

  def current_note
    notes
    .where("notes.valid_until <= ? or notes.valid_until IS NULL", Date.current)
    .order("valid_until DESC NULLS FIRST, id DESC")
    .first
  end
  
  def current_acknowledge
    acknowledges
    .where("notes.valid_until <= ? or notes.valid_until IS NULL", Date.current)
    .order("valid_until DESC NULLS FIRST, id DESC")
    .first
  end

end
