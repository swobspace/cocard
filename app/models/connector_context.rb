class ConnectorContext < ApplicationRecord
  # -- associations
  belongs_to :connector, optional: false
  belongs_to :context, optional: false

  # -- configuration
  acts_as_list scope: :connector

  # -- validations and callbacks
  validates :connector_id, presence: true,
                           uniqueness: { scope: :context_id, allow_blank: false }
  validates :context_id,   presence: true,
                           uniqueness: { scope: :connector_id, allow_blank: false }

end
