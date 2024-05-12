class AddMoreFieldsToCard < ActiveRecord::Migration[7.1]
  def change
    add_reference :cards, :operational_state
    add_reference :cards, :location
    add_column :cards, :lanr, :string, default: ""
    add_column :cards, :bsnr, :string, default: ""
    add_column :cards, :fachrichtung, :string, default: ""
    add_column :cards, :telematikid, :string, default: ""
  end
end
