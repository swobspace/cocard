class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true
  belongs_to :user
  has_rich_text :description
end
