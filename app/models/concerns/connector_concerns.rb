module ConnectorConcerns
  extend ActiveSupport::Concern

  included do
    scope :condition, -> (state) do 
      where('connectors.condition = ?', state)
      .where(manual_update: false)
    end
    scope :ok, -> { condition(Cocard::States::OK) }
    scope :warning, -> { condition(Cocard::States::WARNING) }
    scope :critical, -> { condition(Cocard::States::CRITICAL) }
    scope :unknown, -> { condition(Cocard::States::UNKNOWN) }
    scope :nothing, -> { condition(Cocard::States::NOTHING) }
    scope :failed, -> do
      where("connectors.condition > ?", Cocard::States::OK)
      .where(manual_update: false)
    end

    scope :with_description_containing, ->(query) { joins(:rich_text_description).merge(ActionText::RichText.where <<~SQL, "%" + query + "%") }
    body ILIKE ?
   SQL
  end

  def sds_port
    uri = URI(sds_url).port
  end

  def soap_port
    ( use_tls ) ? 443 : 80
  end

  def rmi
    @rmi ||= Connectors::RMI.new(connector: self)
  end
  
  def supports_rmi? 
    rmi.supported?
  end
  
  def rebootable?
    @rebootable ||= rmi.available_actions.include?(:reboot)
  end

  def rebooted?
    return nil if rebooted_at.nil?
    if rebooted_at > 20.minutes.before(Time.current)
      true
    else
      update_column(:rebooted_at, nil)
      false
    end
  end

  def reboot_active?
    rebooted_at.present? and (rebooted_at > 1.minute.before(Time.current))
  end

  def use_ticlient?
    return false unless Cocard.enable_ticlient
    identification == 'RISEG-RHSK'    
  end

  def can_authenticate?(client = nil)
    case authentication
    when "noauth"
      return true
    when "basicauth"
      return true if (auth_user.present? and auth_password.present?)
    when "clientcert"
      client_certificates.active.where(client_system: client).any? ||
      ClientCertificate.active.tagged_with(client)
                       .joins(:connectors).where(connectors: {id: self.id})
                       .any?
    end
  end

  def smcbs
    card_terminals.joins(card_terminal_slots: :card)
    .where("cards.card_type = 'SMC-B'")
  end
end
