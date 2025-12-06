require 'rails_helper'

RSpec.describe CardTerminals::RMI::RemotePairingJob, type: :job do
  let(:ct)   { FactoryBot.create(:card_terminal, :with_mac) }
  describe '#perform_later' do

    describe "without arguments" do
      it 'matches with enqueued job without args' do
        expect do
          CardTerminals::RMI::RemotePairingJob.perform_later
        end.to have_enqueued_job(CardTerminals::RMI::RemotePairingJob)
      end

      it 'raises an error' do
        expect do
          CardTerminals::RMI::RemotePairingJob.perform_now
        end.to raise_error(KeyError)
      end
    end

    describe "with card terminal" do
      subject { CardTerminals::RMI::RemotePairingJob.perform_now(card_terminal: ct) }

      it 'matches with enqueued job with connector' do
        expect do
          CardTerminals::RMI::RemotePairingJob.perform_later(card_terminal: ct)
        end.to have_enqueued_job(CardTerminals::RMI::RemotePairingJob).with(card_terminal: ct)
      end

    end
  end
end

