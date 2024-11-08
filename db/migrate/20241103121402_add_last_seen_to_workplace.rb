class AddLastSeenToWorkplace < ActiveRecord::Migration[7.1]
  def change
    add_column :workplaces, :last_seen, :timestamp
  end
end
