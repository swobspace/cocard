class AddMailStuffToNote < ActiveRecord::Migration[7.2]
  def change
    add_column :notes, :subject, :string
    add_column :notes, :mail_to, :string
  end
end
