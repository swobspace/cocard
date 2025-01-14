class AddMutedToSinglePicture < ActiveRecord::Migration[7.2]
  def change
    add_column :situation_picture, :muted, :boolean, default: false
  end
end
