module SoftDeletionController
  extend ActiveSupport::Concern

  included do
    before_action :set_deletable, only: %i[undelete soft_delete]
  end

  def undelete
    @deletable.undelete
    respond_with(@deletable)
  end

  def soft_delete
    unless @deletable.soft_delete
      flash[:alert] = @deletable.errors.full_messages.join("; ")
    end
    respond_with(@deletable)
  end

  private
  def set_deletable
    @deletable = controller_name.classify.constantize.with_deleted.find(params[:id])
  end
end
