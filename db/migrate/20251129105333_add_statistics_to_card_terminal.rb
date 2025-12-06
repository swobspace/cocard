class AddStatisticsToCardTerminal < ActiveRecord::Migration[7.2]
  def change
    add_column :card_terminals, :uptime_total, :integer, default: 0
    add_column :card_terminals, :uptime_reboot, :integer, default: 0
    add_column :card_terminals, :slot1_plug_cycles, :integer, default: 0
    add_column :card_terminals, :slot2_plug_cycles, :integer, default: 0
    add_column :card_terminals, :slot3_plug_cycles, :integer, default: 0
    add_column :card_terminals, :slot4_plug_cycles, :integer, default: 0
  end
end
