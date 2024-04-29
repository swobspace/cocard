class AddPositionDefaultToConnectorContext < ActiveRecord::Migration[7.1]
  def change
    change_column_default :connector_contexts, :position, 0
  end
end
