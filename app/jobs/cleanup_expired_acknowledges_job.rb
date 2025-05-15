# CleanupExpiredAcknowlegdesJob.perform_later()
#
# acknowledge_id wird nicht in allen Fällen bei Ablauf der Gültigkeit
# auf Null gesetzt, z.B. wenn das Terminal offline ist und die SMC-KT
# darin nicht mehr aktualisiert werden kann.
#
class CleanupExpiredAcknowledgesJob < ApplicationJob
  queue_as :default

  def perform()
    Note.where(type: :acknowledge, valid_until: ..Time.current).each do |ack|
      if ack.notable.nil?
        ack.destroy # should not occur
      elsif !ack.notable.acknowledge_id.nil?
        ack.notable.update(acknowledge_id: nil)
      end
    end
  end
end
