class UpdateConditionMessage < ActiveRecord::Migration[7.1]
  #
  # update condition message with current state as initial start value
  #
  def up
    (Connector.all + CardTerminal.all + Card.all).each do |c|
      next unless c.condition_message == '-'
      c.update_condition
      c.save
    end
  end

  def down
    # do nothing
  end
end
