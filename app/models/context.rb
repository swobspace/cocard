class Context < ApplicationRecord
  # -- associations
  has_many :card_contexts, dependent: :destroy
  has_many :connector_contexts, dependent: :destroy
  has_many :cards, through: :card_contexts
  has_many :connectors, through: :connector_contexts

  # -- configuration
  # -- validations and callbacks
  validates :mandant, presence: true, 
                      uniqueness: { scope: %i[ client_system  workplace],
                                    allow_blank: false }
  validates :client_system, presence: true, 
                      uniqueness: { scope: %i[ mandant  workplace],
                                    allow_blank: false }
  validates :workplace, presence: true, 
                      uniqueness: { scope: %i[ client_system  mandant],
                                    allow_blank: false }

  # -- common methods
  def to_s
    str = "#{mandant} - #{client_system} - #{workplace}"
    if description.present?
      str + " - #{description}"
    else
      str
    end
  end

end
