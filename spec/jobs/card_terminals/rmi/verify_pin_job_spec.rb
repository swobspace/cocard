require 'rails_helper'

RSpec.describe CardTerminals::RMI::VerifyPinJob, type: :job do
  let(:card) { FactoryBot.create(:card) }
  let(:ct)   { instance_double(CardTerminal) }
  describe '#perform_later' do

    describe "without arguments" do
      it 'matches with enqueued job without args' do
        expect do
          CardTerminals::RMI::VerifyPinJob.perform_later
        end.to have_enqueued_job(CardTerminals::RMI::VerifyPinJob)
      end

      it 'raises an error' do
        expect do
          CardTerminals::RMI::VerifyPinJob.perform_now
        end.to raise_error(KeyError)
      end
    end

    describe "with card" do
      subject { CardTerminals::RMI::VerifyPinJob.perform_now(card: card) }

      it 'matches with enqueued job with connector' do
        expect do
          CardTerminals::RMI::VerifyPinJob.perform_later(card: card)
        end.to have_enqueued_job(CardTerminals::RMI::VerifyPinJob).with(card: card)
      end

      it 'no card terminal => returns false' do
        expect(subject).to be_falsey
      end

      it 'pin_mode == off => returns false' do
        allow(card).to receive(:card_terminal).and_return(ct)
        allow(ct).to receive(:pin_mode).and_return("off")
        expect(subject).to be_falsey
      end

      it 'SMC-KT => returns false' do
        allow(card).to receive(:card_terminal).and_return(ct)
        allow(ct).to receive(:pin_mode).and_return("On Demand")
        allow(card).to receive(:card_type).and_return("SMC-KT")
        expect(subject).to be_falsey
      end
    end
  end
end

