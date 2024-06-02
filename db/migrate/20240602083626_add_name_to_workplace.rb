class AddNameToWorkplace < ActiveRecord::Migration[7.1]
  def change
    add_column :workplaces, :name, :string, default: ''
  end
end
