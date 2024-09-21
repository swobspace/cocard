# frozen_string_literal: true

module NotableConcerns
  extend ActiveSupport::Concern

  included do
    belongs_to :acknowledge, class_name: 'Note', optional: true
    has_many :notes, as: :notable, dependent: :destroy
    has_many :plain_notes, -> { where(type: types[:plain]) },
             as: :notable, class_name: 'Note', dependent: :destroy
    has_many :acknowledges, -> { where(type: types[:acknowledge]) },
             as: :notable, class_name: 'Note', dependent: :destroy

    scope :acknowledged, -> { joins(:acknowledge) }
    scope :not_acknowledged, -> { where(acknowledge_id: nil) }
  end

  def current_note
    # plain_notes.active.order("valid_until DESC NULLS FIRST, id DESC").first
    plain_notes.active.order("id DESC").first
  end
  
  def current_acknowledge
    # acknowledges.active.order("valid_until DESC NULLS FIRST, id DESC").first
    acknowledges.active.order("id DESC").first
  end

  def close_acknowledge
    return if acknowledge.nil?
    ActiveRecord::Base.transaction do
      acknowledge.update(valid_until: Time.current)
      update(acknowledge_id: nil)
    end
  end

end
