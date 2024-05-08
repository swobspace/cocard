class ChangeNullOnConnectorInCardTerminal < ActiveRecord::Migration[7.1]
  def change
    change_column_null :card_terminals, :connector_id, true
  end
end
