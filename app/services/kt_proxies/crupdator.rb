# frozen_string_literal: true

module KTProxies
  #
  # Creates a kt_proxy if not exist
  # creates or updates a kt_proxy if kt_proxy.present?
  #
  class Crupdator
    attr_reader :proxy_hash, :ti_client

    # crupd = KTProxies::Crupdator(options)
    #
    # mandantory options:
    # * :ti_client
    # * :proxy_hash
    #
    def initialize(options = {})
      options.symbolize_keys
      @ti_client  = options.fetch(:ti_client)
      @proxy_hash = options.fetch(:proxy_hash)
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def save
      if by_uuid
        by_uuid.update(common_attributes.merge(
                                           name: name, 
                                           card_terminal_ip: card_terminal_ip)
                                         )
      elsif by_name_and_ip
        by_name_and_ip.update(common_attributes.merge(uuid: uuid))
      elsif by_ip
        by_ip.update(common_attributes.merge(uuid: uuid,
                                                     name: name))
      else
        KTProxy.create(common_attributes
                       .merge(uuid: uuid, name: name, 
                              card_terminal_ip: card_terminal_ip)
                       .merge(card_terminal_via_ip)
                      )
      end
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations

  private
    def by_uuid
      ktp = KTProxy.where(uuid: uuid)
      if ktp.size == 1
        ktp.first
      elsif ktp.size > 1
        raise RuntimeError, "duplicate uuid, should not possible!"
      else
        nil
      end
    end

    def by_name_and_ip
      ktp = KTProxy.where(name: name, card_terminal_ip: card_terminal_ip)
      if ktp.size == 1
        ktp.first
      elsif ktp.size > 1
        raise RuntimeError, "duplicate ktproxy, should not possible!"
      else
        nil
      end
    end

    def by_ip
      ktp = KTProxy.where(card_terminal_ip: card_terminal_ip)
      if ktp.size == 1
        ktp.first
      elsif ktp.size > 1
        # more than one ktproxy with same ip found
        puts ktp.size
        nil
      else
        nil
      end
    end

    def common_attributes
      {
        ti_client_id:       ti_client.id,
        wireguard_ip:       proxy_hash['wireguardIp'],
        incoming_ip:        proxy_hash['incomingIp'],
        incoming_port:      proxy_hash['incomingPort'],
        outgoing_ip:        proxy_hash['outgoingIp'],
        outgoing_port:      proxy_hash['outgoingPort'],
        card_terminal_port: proxy_hash['cardTerminalPort']
      }
    end

    def uuid
      proxy_hash['id']
    end

    def name
      proxy_hash['name']
    end

    def card_terminal_ip
      proxy_hash['cardTerminalIp']
    end

    def card_terminal_via_ip
      cts = CardTerminal.where(ip: card_terminal_ip)
      if cts.count == 1
        { card_terminal_id: cts.first.id }
      else
        { }
      end
    end

  end
end
