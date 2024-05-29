class Log < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
