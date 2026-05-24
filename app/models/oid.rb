class Oid < ApplicationRecord
  # -- associations
  # -- configuration
  # -- validations and callbacks
  validates :oid, presence: true,
                   uniqueness: { case_sensitive: false, allow_blank: false }
  validates :name, presence: true

  # -- common methods
  def to_s
    "#{oid} - #{name}"
  end

  def to_label
    "#{name} (#{oid})"
  end

end
