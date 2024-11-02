# frozen_string_literal: true

module TI::SinglePictures
  #
  # Create or update a log entry
  #
  class Creator
    attr_reader :single_picture

    # creator = TI::SinglePictures::Creator(options)
    #
    # mandantory options:
    # * :sp        - object (TI::SinglePicture)
    #
    def initialize(options = {})
      options.symbolize_keys
      @sp        = options.fetch(:sp)
    end

    def save
      return false unless @sp.ci.present?
      @single_picture = SinglePicture.find_or_initialize_by(ci: @sp.ci) do |sp|
                          TI::SinglePicture::ATTRIBUTES.each do |attr|
                            next if attr == :ci
                            sp.send("#{attr}=", @sp.send(attr))
                          end
                        end

      if @single_picture.persisted?
        TI::SinglePicture::ATTRIBUTES.each do |attr|
          next if attr == :ci
          @single_picture.send("#{attr}=", @sp.send(attr))
        end
      end
      if @single_picture.save
        true
      else
        Rails.logger.warn("WARN:: could not create or save single picture #{@sp.ci}: " +
          @single_picture.errors.full_messages.join('; '))
        false
      end
    end

  private
    
  end
end
