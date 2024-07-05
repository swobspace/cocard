class AddSinceToLog < ActiveRecord::Migration[7.1]
  def change
    add_column :logs, :since, :timestamp
  end
end
