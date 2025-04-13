require 'rails_helper'

RSpec.describe CardTerminals::ConnectivityCheckJob, type: :job do
  let(:card_terminal) { FactoryBot.create(:card_terminal, :with_mac) }
  describe '#perform_later' do
    it 'matches with enqueued job without args' do
      expect do
        CardTerminals::ConnectivityCheckJob.perform_later
      end.to have_enqueued_job(CardTerminals::ConnectivityCheckJob)
    end

    it 'matches with enqueued job with card_terminal' do
      expect do
        CardTerminals::ConnectivityCheckJob.perform_later(card_terminal: card_terminal)
      end.to have_enqueued_job(CardTerminals::ConnectivityCheckJob).with(card_terminal: card_terminal)
    end
  end
end
