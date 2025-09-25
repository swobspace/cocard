class CardTerminalsDatatable < ApplicationDatatable

  def initialize(relation, view)
    @view = view
    @relation = relation
  end

  private
  attr_reader :relation

  def data
    card_terminals.map do |ct|
      [].tap do |column|
        column << render(ConditionIconComponent.new(item: ct, small: true, as_text: true))
        column <<  ct.condition_message
        column <<  link_to(ct.displayname, @view.card_terminal_path(ct),
                           class: 'primary-link')
        column <<  link_to(ct.ct_id, @view.card_terminal_path(ct),
                           class: 'primary-link')
        column <<  (link_to(ct.connector&.name,
                            @view.connector_path(ct.connector),
                            class: 'primary-link'
                            ) if ct.connector)
        column <<  ct.name
        column <<  ct.mac.to_s
        column <<  ct.ip.to_s
        column <<  ct.connected.to_s
        column <<  ct.location&.lid
        column <<  ct.tag_list.join(", ")
        column <<  ct.room
        column <<  ct.plugged_in
        column <<  ct.contact
        column <<  ct.idle_message
        column <<  ct.delivery_date.to_s
        column <<  ct.supplier
        column <<  ct.serial
        column <<  ct.id_product
        column <<  ct.firmware_version
        column <<  ct.description.to_plain_text
        column << I18n.t(ct.pin_mode, scope: 'pin_modes').to_s
        column <<  ct.smckt&.iccsn.to_s
        column << render(Card::ExpirationDateComponent.new(card: ct.smckt))
        column << render(IsCurrentComponent.new(item: ct, attr: :last_check))
        column << render(IsCurrentComponent.new(item: ct, attr: :last_ok))

        links = []
        links << show_link(ct)
        links << render(HealthCheckButtonComponent.new(item: ct))
        links << edit_link(ct)
        links << delete_link(ct)
        column << links.join(' ')
      end
    end
  end

  def count
    @relation.count
  end

  def total_entries
    if params['length'] == "-1"
      CardTerminal.count
    else
      card_terminals_query.count
    end
  end

  def card_terminals
    @card_terminals ||= fetch_card_terminals
  end

  def card_terminals_query
    if params[:order]
      terminals = relation.order("#{sort_column} #{sort_direction}")
    else
      terminals = relation
    end
    terminals = CardTerminals::Query.new(terminals,
                                         search_params(params, search_columns)
                                        ).all.distinct
  end

  def fetch_card_terminals
    if params['length'] == "-1"
      card_terminals = card_terminals_query
    else
      # @pagy, card_terminals = pagy(card_terminals_query, count: total_entries, page: page, limit: per_page)
      card_terminals = card_terminals_query.offset((page - 1)*per_page).limit(per_page)
    end
    card_terminals
  end

  def columns
    %w[ card_terminals.condition
        card_terminals.condition_message
        card_terminals.displayname
        card_terminals.ct_id
        card_terminals.connector_id
        card_terminals.name
        card_terminals.mac
        card_terminals.ip
        card_terminals.connected
        card_terminals.location_id
        ""
        card_terminals.room
        card_terminals.plugged_in
        card_terminals.contact
        card_terminals.idle_message
        card_terminals.delivery_date
        card_terminals.supplier
        card_terminals.serial
        card_terminals.id_product
        card_terminals.firmware_version
        ""
        card_terminals.pin_mode
        ""
        ""
        card_terminals.last_check
        card_terminals.last_ok
      ]
  end

  def search_columns
    %w[ condition
        condition_message
        displayname
        ct_id
        connector
        name
        mac
        ip
        connected
        lid
        tag
        room
        plugged_in
        contact
        idle_message
        delivery_date
        supplier
        serial
        id_product
        firmware_version
        description
        pin_mode
        iccsn
        expiration_date
        last_check
        last_ok
     ]
  end
end
