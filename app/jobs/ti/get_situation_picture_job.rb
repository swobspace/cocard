module TI
  # 
  # Fetch TI_Lagebild (json array)
  #
  class GetSituationPictureJob < ApplicationJob
    queue_as :default

    def perform(options = {})
      options.symbolize_keys!

      result = TI::SituationPicture::Fetch.new().call
      if result.success?
        result.situation_picture.each do |ti_sp|
          creator = TI::SinglePictures::Creator.new(sp: ti_sp)
          unless creator.save
            msg = "WARN:: can't save single picture: " +
                  result.error_messages.join("\n")
            Rails.logger.warn(msg)
          end
        end
      else
        msg = "WARN:: TI::SituationPicture::Fetch failed; " +
              result.error_messages.join("\n")
        Rails.logger.warn(msg)
      end
      Turbo::StreamsChannel.broadcast_refresh_later_to(:ti_lagebild)
    end

    def max_attempts
      0
    end

    private
  end
end
