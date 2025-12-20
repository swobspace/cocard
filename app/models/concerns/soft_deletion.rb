module SoftDeletion
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }
  end

  def soft_delete
    if has_attribute? :deleted_at
      update(deleted_at: Time.current)
    end
  end

  def deleted?
    deleted_at.present?
  end

end
