class OutdatedJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Card.where("last_check is NULL or last_check < ?", 1.day.before(Time.current))
        .map(&:save)
    CardTerminal.where("last_check is NULL or last_check < ?", 1.day.before(Time.current))
                .map(&:save)
  end
end
