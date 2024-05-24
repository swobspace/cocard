# frozen_string_literal: true

module CardTerminals
  #
  # Create or update CardTerminal
  #
  class Creator
    attr_reader :channel

    # creator = CardTerminal::Creator(options)
    #
    # mandantory options:
    # * :connector  - connector object
    # * :cct        - Cocard::CardTerminal object
    #
    def initialize(options = {})
      options.symbolize_keys
      @connector = options.fetch(:connector)
      @cct       = options.fetch(:cct)
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def save
      @card_terminal = CardTerminal.find_or_initialize_by(mac: cct.mac) do |ct|
                         Cocard::CardTerminal::ATTRIBUTES.each do |attr|
                           next if attr == :mac
                           ct.send("#{attr}=", cct.send(attr))
                         end
                         ct.connector_id = connector.id
                       end

      if @card_terminal.persisted?
        #
        # Connector may deliver old data from info model, so
        # avoid clash with data from the current real connector
        #
        if !cct.connected && @card_terminal.connector_id != connector.id
          return false
        end
        #
        # Update attributes
        #
        Cocard::CardTerminal::ATTRIBUTES.each do |attr|
          next if attr == :mac
          @card_terminal.send("#{attr}=", cct.send(attr))
        end
        @card_terminal.connector_id = connector.id
        @card_terminal.update_condition
      end

      @card_terminal.firmware_version = @card_terminal.product_information&.firmware_version

      if @card_terminal.save
        @card_terminal.touch
      else
        Rails.logger.warn("WARN:: could not create or save card terminal #{@card_terminal.mac}: " +
          @card_terminal.errors.full_messages.join('; '))
        false
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations

    private

    attr_reader :cct, :connector

  end
end
