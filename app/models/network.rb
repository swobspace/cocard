class Network < ApplicationRecord
  belongs_to :location
  has_rich_text :description
end
