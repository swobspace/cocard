module CardTerminals
  class RMI
    class RemotePairingJob < ApplicationJob
      queue_as :rmi

      def perform(options = {})
        options = options.symbolize_keys
        card_terminal = options.fetch(:card_terminal)
        @user         = options.fetch(:user)
        @prefix = "RemotePairingJob:: CardTerminal ".freeze
        unless check_job_requirements(card_terminal)
          msg = @prefix + "not all requirements met"
          Rails.logger.warn(msg)
          toaster(card_terminal, :warning, msg)
          return false
        end

        card_terminal.rmi.remote_pairing do |result|
          result.on_success do |message|
            msg = @prefix + "successful"
            Rails.logger.info(msg)
            toaster(card_terminal, :success, msg)
            return true
          end
          result.on_failure do |message|
            msg = @prefix + "#{message}"
            Rails.logger.error(msg)
            toaster(card_terminal, :alert, msg)
            return false
          end
          result.on_unsupported do
            msg = @prefix + "Terminal or action not supported"
            Rails.logger.warn(msg)
            toaster(card_terminal, :warning, msg)
            return false
          end
        end
      end

    private
      attr_reader :prefix, :card_terminal
      def check_job_requirements(ct)
        if !ct.supports_rmi?
          Rails.logger.warn(prefix + "CardTerminal does not meet requirements")
          false
        else
          true
        end
      end

      def toaster(card_terminal, status, message)
        message = "#{card_terminal}: #{message}"
        unless status.nil?
          Turbo::StreamsChannel.broadcast_prepend_to(
            @user,
            target: 'toaster',
            partial: "shared/turbo_toast",
            locals: {status: status, message: message})
        end
      end
    end
  end
end
