class Context < ApplicationRecord
  # -- associations
  has_many :connector_contexts
  has_many :cards, dependent: :restrict_with_error
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
    "#{mandant} - #{client_system} - #{workplace}"
  end

end
