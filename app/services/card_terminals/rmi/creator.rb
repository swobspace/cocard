# frozen_string_literal: true

module CardTerminals
  #
  # Create or update CardTerminal from RMI get_info
  #
  class RMI::Creator
    attr_reader :card_terminal

    # creator = CardTerminal::Creator(info: info)
    #
    # mandantory options:
    # * :info  - CardTerminal::RMI::*::Info object
    #
    def initialize(options = {})
      options.symbolize_keys
      @info = options.fetch(:info)
    end

    def save
      @card_terminal = CardTerminal.find_or_initialize_by(mac: info.macaddr) do |c|
                         c.ip = info.current_ip
                         c.name = info.terminalname
                         c.identification = info.identification
                         c.firmware_version = info.firmware_version
                         c.serial = info.serial
                         c.uptime_total = info.uptime_total
                         c.uptime_reboot = info.uptime_reboot
                         c.slot1_plug_cycles = info.slot1_plug_cycles
                         c.slot2_plug_cycles = info.slot2_plug_cycles
                         c.slot3_plug_cycles = info.slot3_plug_cycles
                         c.slot4_plug_cycles = info.slot4_plug_cycles
                       end

      if @card_terminal.persisted?
        @card_terminal.ip = info.current_ip
        @card_terminal.name = info.terminalname
        @card_terminal.identification = info.identification
        @card_terminal.firmware_version = info.firmware_version
        @card_terminal.serial = info.serial
        @card_terminal.uptime_total = info.uptime_total
        @card_terminal.uptime_reboot = info.uptime_reboot
        @card_terminal.slot1_plug_cycles = info.slot1_plug_cycles
        @card_terminal.slot2_plug_cycles = info.slot2_plug_cycles
        @card_terminal.slot3_plug_cycles = info.slot3_plug_cycles
        @card_terminal.slot4_plug_cycles = info.slot4_plug_cycles
      end

      # @card_terminal.last_check = Time.current

      #
      # final save
      #
      if @card_terminal.save
        @card_terminal.touch
        update_or_create_card
      else
        Rails.logger.warn("WARN:: could not create or save card terminal #{@card_terminal.mac}: " +
          @card_terminal.errors.full_messages.join('; '))
        false
      end
    end

    private
    attr_reader :info

    def update_or_create_card
      iccsn = info.smckt_iccsn
      return if (iccsn.blank? or iccsn == '-')
      expiration = info.smckt_auth2_expiration || info.smckt_auth1_expiration
      card = Card.find_or_create_by(iccsn: iccsn) do |c|
                    c.card_type = 'SMC-KT'
                    c.expiration_date = expiration
                  end
      if info.smckt_slot > 0
        slot = CardTerminalSlot.find_or_create_by!(card_terminal_id: @card_terminal.id,
                                                   slotid: info.smckt_slot)
              # remove slot reference from older other card
        if slot.card && slot.card != card
          slot.card.update(card_terminal_slot_id: nil)
        end
        card.update(card_terminal_slot_id: slot.id)
      end
    end

  end
end
