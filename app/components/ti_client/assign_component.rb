# frozen_string_literal: true

class TIClient::AssignComponent < ViewComponent::Base
  def initialize(ti_client:, terminal:)
    @ti_client = ti_client
    @terminal = terminal
    unless @terminal.kind_of?(RISE::TIClient::Konnektor::Terminal)
      raise RuntimeError, "Terminal hat den falschen Typ #{terminal.class.name}"
    end
  end

  def render?
    terminal.present? and ti_client.present? and (assignable || aktiv)
  end

  def icon
    if bekannt
      raw(%Q[<i class="fa-solid fa-fw fa-plus"></i>])
    elsif zugewiesen
      raw(%Q[<i class="fa-solid fa-fw fa-link"></i>])
    elsif aktiv
      raw(%Q[<i class="fa-solid fa-fw fa-check"></i>])
    else
      ""
    end
  end

  def title
    if bekannt
      "Terminal am Konnektor zuweisen"
    elsif zugewiesen
      "Pairing-Vorgang am Konnektor und Terminal starten"
    elsif aktiv
      "Terminal aktiv"
    end
  end

  def action
    if bekannt
      assign_ti_client_terminal_path(id: ti_client.id, method: :post,
                                     params: {ct_id: terminal.ct_id}
                                    )
    elsif zugewiesen
      pairing_ti_client_terminal_path(id: ti_client.id, method: :post,
                                     params: {card_terminal_id: terminal.card_terminal.id}
                                    )
    else
      nil
    end
  end

  def button_class
    if bekannt
      "btn btn-sm btn-warning me-1"
    elsif zugewiesen
      "btn btn-sm btn-warning me-1"
    elsif aktiv
      "btn btn-sm btn-success me-1"
    end
  end

private
  attr_reader :ti_client, :terminal

  def bekannt
    terminal.correlation == "BEKANNT"
  end
  
  def zugewiesen
    terminal.correlation == "ZUGEWIESEN"
  end
  
  def aktiv
    terminal.correlation == "AKTIV"
  end
  
  def assignable
    bekannt || zugewiesen || aktiv
  end
  
end
