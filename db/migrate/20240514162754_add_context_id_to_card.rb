class AddContextIdToCard < ActiveRecord::Migration[7.1]
  def change
    add_reference :cards, :context, null: true, foreign_key: false
  end
end
