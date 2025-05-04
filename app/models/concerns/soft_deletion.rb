module SoftDeletion
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }
  end

  def soft_delete
    if has_attribute? :deleted_at
      update_column :deleted_at, Time.current
    end
  end

end
