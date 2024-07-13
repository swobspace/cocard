class CardContext < ApplicationRecord
  # -- associations
  belongs_to :card, optional: false, inverse_of: :card_contexts
  belongs_to :context, optional: false, inverse_of: :card_contexts

  # -- configuration
  acts_as_list scope: :card

  # -- validations and callbacks
  validates :card_id, presence: true,
                           uniqueness: { scope: :context_id, allow_blank: false }
  validates :context_id,   presence: true,
                           uniqueness: { scope: :card_id, allow_blank: false }


end
