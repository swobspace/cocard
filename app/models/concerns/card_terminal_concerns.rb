module CardTerminalConcerns
  extend ActiveSupport::Concern

  included do
    scope :condition, -> (state) do
      where('card_terminals.condition = ?', state)
    end
    scope :ok, -> { condition(Cocard::States::OK) }
    scope :warning, -> { condition(Cocard::States::WARNING) }
    scope :critical, -> { condition(Cocard::States::CRITICAL) }
    scope :unknown, -> { condition(Cocard::States::UNKNOWN) }
    scope :nothing, -> { condition(Cocard::States::NOTHING) }
    scope :failed, -> do
      where("card_terminals.condition > ?", Cocard::States::OK)
    end

    scope :with_description_containing, ->(query) { joins(:rich_text_description).merge(ActionText::RichText.where <<~SQL, "%" + query + "%") }
    body ILIKE ?
   SQL
  end

  def update_location_by_ip
    return if ip.blank?
    nets = Network.best_match(ip)
    net = nets.first
    unless net.nil?
      self[:network_id] = net.id
      unless net.location_id.nil?
        self[:location_id] = net.location_id
      end
    end
  end

  def scoped_workplaces(mandant, client_system)
    workplaces
    .where(terminal_workplaces: {mandant: mandant, client_system: client_system})
  end

  def smcb
    cards.where(card_type: 'SMC-B')
  end

  def has_smcb?
    smcb.any?
  end

  def smckt
    cards.where(card_type: 'SMC-KT').first
  end

  def default_idle_message
    template = Liquid::Template.parse(Cocard.ct_idle_message_template)
    template.render(to_liquid)
  end

  def to_liquid
    {
      "has_smcb?" => has_smcb?,
      "displayname" => displayname,
      "location" => location&.lid,
      "name" => name,
      "ct_id" => ct_id,
      "mac" => mac.to_s,
      "ip" => ip.to_s,
      "connector" => connector&.name.to_s,
      "connector_short_name" => connector&.short_name.to_s,
      "firmware_version" => firmware_version,
      "serial" => serial,
      "id_product" => id_product,
      "network" => network.to_s
    }
  end

  def supports_rmi?
   CardTerminals::RMI::Base.new(card_terminal: self).valid
  end

  def rebootable?
    rmi = CardTerminals::RMI::Base.new(card_terminal: self)
    if rmi.nil?
      false
    else
      rmi.respond_to?(:reboot)
    end
  end

  def rebooted?
    return nil if rebooted_at.nil?
    if rebooted_at > 5.minutes.before(Time.current)
      true
    else
      update_column(:rebooted_at, nil)
      false
    end
  end

  def reboot_active?
    rebooted_at.present? and (rebooted_at > 2.minute.before(Time.current))
  end

  # may be later replaced by attribute :rmi_port
  def rmi_port
    default_rmi_port
  end

  # get default port from rmi class
  def default_rmi_port
    rmi = CardTerminals::RMI::Base.new(card_terminal: self)
    if rmi.nil? || !rmi.valid
      0
    else
      rmi.rmi.class::RMI_PORT
    end
  end

  def use_ktproxy?
    return false unless Cocard.enable_ticlient
    return true if kt_proxy.present? 
    return false unless connector.present?
    connector.use_ticlient?
  end
end
