module CardTerminals
  class RMI
    class RemotePairingJob < ApplicationJob
      queue_as :rmi

      def perform(options = {})
        options = options.symbolize_keys
        card_terminal = options.fetch(:card_terminal)
        @prefix = "RemotePairingJob:: CardTerminal #{card_terminal}:: ".freeze
        unless check_job_requirements(card_terminal)
          Rails.logger.warn(@prefix + "not all requirements met")
          return false
        end

        card_terminal.rmi.remote_pairing do |result|
          result.on_success do |message|
            Rails.logger.info(@prefix + "successful")
            return true
          end
          result.on_failure do |message|
            Rails.logger.error(@prefix + "#{message}")
            return false
          end
          result.on_unsupported do
            Rails.logger.warn(@prefix + "Terminal or action not supported")
            return false
          end
        end
      end

    private
      attr_reader :prefix
      def check_job_requirements(ct)
        if !ct.supports_rmi?
          Rails.logger.warn(prefix + "CardTerminal does not meet requirements")
          false
        else
          true
        end
      end
    end
  end
end
