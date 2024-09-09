# frozen_string_literal: true

module NotableConcerns
  extend ActiveSupport::Concern

  included do
    has_many :notes, as: :notable, dependent: :destroy
    has_many :plain_notes, -> { where(type: types[:plain]) },
             as: :notable, class_name: 'Note', dependent: :destroy
    has_many :acknowledges, -> { where(type: types[:acknowledge]) },
             as: :notable, class_name: 'Note', dependent: :destroy
  end

  def current_note
    plain_notes.active.order("valid_until DESC NULLS FIRST, id DESC").first
  end
  
  def current_acknowledge
    acknowledges.active.order("valid_until DESC NULLS FIRST, id DESC").first
  end

end
