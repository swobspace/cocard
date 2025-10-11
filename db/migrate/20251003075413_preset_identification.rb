class PresetIdentification < ActiveRecord::Migration[7.2]
  def up
    CardTerminal.where.not(properties: nil).each do |ct|
      identification = "#{ct.product_information&.product_vendor_id}-#{ct.product_information&.product_code}"
      ct.update(identification: identification)
    end
  end

  def down
  end
end
