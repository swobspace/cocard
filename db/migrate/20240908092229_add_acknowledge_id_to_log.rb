class AddAcknowledgeIdToLog < ActiveRecord::Migration[7.1]
  def change
    add_column :logs, :acknowledge_id, :bigint
  end
end
