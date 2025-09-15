require 'rails_helper'

RSpec.describe CardTerminals::RMI::SetIdleMessageJob, type: :job do
  let(:ct)   { FactoryBot.create(:card_terminal, :with_mac) }
  describe '#perform_later' do

    describe "without arguments" do
      it 'matches with enqueued job without args' do
        expect do
          CardTerminals::RMI::SetIdleMessageJob.perform_later
        end.to have_enqueued_job(CardTerminals::RMI::SetIdleMessageJob)
      end

      it 'raises an error' do
        expect do
          CardTerminals::RMI::SetIdleMessageJob.perform_now
        end.to raise_error(KeyError)
      end
    end

    describe "#perform_later with arguments" do
      it 'matches with enqueued job with connector' do
        expect do
          CardTerminals::RMI::SetIdleMessageJob
          .perform_later(card_terminal: ct, idle_message: "Hello World!")
        end.to have_enqueued_job(CardTerminals::RMI::SetIdleMessageJob)
               .with(card_terminal: ct, idle_message: "Hello World!")
      end
    end

    describe "with card_terminal" do
      subject { CardTerminals::RMI::SetIdleMessageJob.perform_now(card_terminal: ct, idle_message: "Hello World!") }

      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive(:identification).and_return('INGHC-ORGA6100')

        ct.update(pin_mode: 'on_demand')
        ct.update_column(:condition, Cocard::States::OK)
        ct.reload
        expect_any_instance_of(CardTerminals::RMI::OrgaV1).to receive(:set_idle_message).with('Hello World!')
        expect_any_instance_of(CardTerminals::RMI::OrgaV1).to receive(:result)
         .at_least(:once).and_return(result)
      end

      describe "successful call" do
        let(:result) {{ 'result' => 'success' }}
        it "calls rmi#set_idle_message" do
          expect(subject).to be_truthy
        end
      end

      describe "not successful call" do
        let(:result) {{ 'result' => 'failure' }}
        it "calls rmi#set_idle_message" do
          expect(subject).to be_falsey
        end
      end
    end
  end
end

