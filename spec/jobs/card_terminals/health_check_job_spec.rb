require 'rails_helper'

RSpec.describe CardTerminals::HealthCheckJob, type: :job do
  let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        CardTerminals::HealthCheckJob.perform_later
      end.to have_enqueued_job(CardTerminals::HealthCheckJob)
    end

    it 'matches with enqueued job with card_terminal' do
      expect do
        CardTerminals::HealthCheckJob.perform_later(card_terminal: card_terminal)
      end.to have_enqueued_job(CardTerminals::HealthCheckJob).with(card_terminal: card_terminal)
    end
  end
end
