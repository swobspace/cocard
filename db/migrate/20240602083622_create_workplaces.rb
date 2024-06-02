class CreateWorkplaces < ActiveRecord::Migration[7.1]
  def change
    create_table :workplaces do |t|

      t.timestamps
    end
  end
end
