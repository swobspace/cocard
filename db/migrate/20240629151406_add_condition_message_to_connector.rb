class AddConditionMessageToConnector < ActiveRecord::Migration[7.1]
  def change
    add_column :connectors, :condition_message, :string, default: '-'
  end
end
