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
end
