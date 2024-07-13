class RenameContextToOld < ActiveRecord::Migration[7.1]
  def change
    rename_column :cards, :context_id, :old_context_id
    rename_column :cards, :pin_status, :old_pin_status
  end
end
