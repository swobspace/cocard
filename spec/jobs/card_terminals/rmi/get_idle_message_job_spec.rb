require 'rails_helper'

RSpec.describe CardTerminals::RMI::GetIdleMessageJob, type: :job do
  let(:card_terminal)   { FactoryBot.create(:card_terminal, :with_mac) }
  describe '#perform_later' do

    describe "without arguments" do
      it 'matches with enqueued job without args' do
        expect do
          CardTerminals::RMI::GetIdleMessageJob.perform_later
        end.to have_enqueued_job(CardTerminals::RMI::GetIdleMessageJob)
      end

      it 'raises an error' do
        expect do
          CardTerminals::RMI::GetIdleMessageJob.perform_now
        end.not_to raise_error
      end
    end

    describe "with card_terminal" do
      subject { CardTerminals::RMI::GetIdleMessageJob.perform_now(card_terminal: card_terminal) }

      it 'matches with enqueued job with connector' do
        expect do
          CardTerminals::RMI::GetIdleMessageJob.perform_later(card_terminal: card_terminal)
        end.to have_enqueued_job(CardTerminals::RMI::GetIdleMessageJob).with(card_terminal: card_terminal)
      end

    end
  end
end

