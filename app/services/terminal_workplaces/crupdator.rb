# frozen_string_literal: true

module TerminalWorkplaces
  #
  # Creates a workplace if not not exist
  # creates or updates a terminal_workplace with scope [:mandant, :client_system]
  # deletes obsolete terminal_workplaces with scope [:mandant, :client_system]
  #
  class Crupdator
    attr_reader :workplaces, :client_system, :mandant, :card_terminal

    # crupd = TerminalWorkplaces::Crupdator(options)
    #
    # mandantory options:
    # * :card_terminal - object
    # * :mandant       - string
    # * :client_system - string
    # * :workplaces    - Array of strings
    #
    # obsolete_workplaces = crupd.call 
    #
    def initialize(options = {})
      options.symbolize_keys
      @card_terminal  = options.fetch(:card_terminal)
      @mandant        = options.fetch(:mandant)
      @client_system  = options.fetch(:client_system)
      @wp_names        = Array(options.fetch(:workplaces))
    end

    # rubocop:disable Metrics/AbcSize, Rails/SkipsModelValidations
    def call
      @workplaces = find_or_create_workplaces_by_name(wp_names)
      @workplaces.each do |wp|
        TerminalWorkplace.find_or_create_by(
          card_terminal_id: card_terminal.id,
          mandant: mandant,
          client_system: client_system,
          workplace_id: wp.id
        )
      end
      obsolete = obsolete_terminal_workplaces(@workplaces)
      TerminalWorkplace.destroy(obsolete.map(&:id))
      obsolete.map{|o| o.workplace}
    end
    # rubocop:enable Metrics/AbcSize, Rails/SkipsModelValidations

  private
    attr_reader :wp_names

    def find_or_create_workplaces_by_name(wp_names)
      [].tap do |wp|
        wp_names.each do |name|
          workplace = Workplace.find_or_create_by(name: name)
          if workplace.persisted?
            workplace.touch(:last_seen)
            wp << workplace
          else
            Rails.logger.warn("WARN:: couldn't not find or create workplace #{name}")
          end
        end
      end
    end

    def obsolete_terminal_workplaces(workplaces)
      card_terminal.terminal_workplaces
                   .where(mandant: mandant, client_system: client_system)
                   .reject{|twp| workplaces.include?(twp.workplace)}
    end
  end
end
