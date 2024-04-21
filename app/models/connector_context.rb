class ConnectorContext < ApplicationRecord
  belongs_to :connector
  belongs_to :context
end
