class AddWithMailToNote < ActiveRecord::Migration[7.2]
  def change
    add_column :notes, :with_mail, :boolean, default: false
  end
end
