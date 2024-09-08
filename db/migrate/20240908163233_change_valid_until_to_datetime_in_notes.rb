class ChangeValidUntilToDatetimeInNotes < ActiveRecord::Migration[7.1]
  def change
    change_column(:notes, :valid_until, :datetime)
  end
end
