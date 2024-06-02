module WorkplaceConcerns
  extend ActiveSupport::Concern

  included do
  end

  def contexts
    terminal_workplaces.pluck(:mandant, :client_system).uniq.map{|m,c| "#{m} - #{c}" }
  end

end
