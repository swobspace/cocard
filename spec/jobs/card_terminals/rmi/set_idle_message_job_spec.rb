require 'rails_helper'

RSpec.describe CardTerminals::RMI::SetIdleMessageJob, type: :job do
  Result = Struct.new(:success?, :message, :value)
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
      let(:orgav1) do
        instance_double(CardTerminals::RMI::OrgaV1,
          supported?: true, 
          rmi_port: 443,
          available_actions: [:reboot, :get_idle_message, :set_idle_message, :verify_pin]
        )
      end

      subject { CardTerminals::RMI::SetIdleMessageJob.perform_now(card_terminal: ct, idle_message: "Hello World!") }

      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive(:identification).and_return('INGHC-ORGA6100')
        expect(CardTerminals::RMI::OrgaV1).to receive(:new).and_return(orgav1)

        # ct.update(pin_mode: 'on_demand')
        ct.update_column(:condition, Cocard::States::OK)
        ct.reload
      end

      describe "successful call" do
        let(:res) { Result.new(success?: true, message: "some text") }
        it "calls rmi#set_idle_message" do
          expect(orgav1).to receive(:set_idle_message).with('Hello World!').and_return(res)
          expect(subject).to be_truthy
        end
      end

      describe "not successful call" do
        let(:res) { Result.new(success?: false, message: "some failure") }
        it "calls rmi#set_idle_message" do
          expect(orgav1).to receive(:set_idle_message).with('Hello World!').and_return(res)
          expect(subject).to be_falsey
        end
      end
    end
  end
end

