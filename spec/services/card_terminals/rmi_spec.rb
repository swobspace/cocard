# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe RMI do
    Result = Struct.new(:success?, :message, :value)
    let(:ct) do
      FactoryBot.create(:card_terminal,
        mac: ENV['CT_MAC'],
        ip: ENV['CT_IP']
      )
    end
    let(:card) do
      FactoryBot.create(:card,
        iccsn: ENV['CARD_ICCSN'],
      )
    end
  
    subject { CardTerminals::RMI.new(card_terminal: ct) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(CardTerminals::RMI) }
      it { expect(subject.respond_to?(:available_actions)).to be_truthy }
      it { expect(subject.respond_to?(:rmi_port)).to be_truthy }
      it { expect(subject.respond_to?(:reboot)).to be_truthy }
      it { expect(subject.respond_to?(:get_idle_message)).to be_truthy }
      it { expect(subject.respond_to?(:set_idle_message)).to be_truthy }
      it { expect(subject.respond_to?(:verify_pin)).to be_truthy }
      it { expect(subject.respond_to?(:remote_pairing)).to be_truthy }
      it { expect(subject.respond_to?(:supported?)).to be_truthy }
    end

    describe '::new' do
      context 'without :card_terminal' do
        it 'raises a KeyError' do
          expect do
            CardTerminals::RMI.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe "without valid identification" do
      it { expect(subject.supported?).to be_falsey }
      it { expect(subject.available_actions).to be_empty }
    end

    ### UNKNOWN terminal ##################################################
    describe "with unknown terminal type" do
      let(:null) do
        instance_double(CardTerminals::RMI::Null, 
          supported?: false, 
          rmi_port: 443,
          available_actions: []
        )
      end
      before(:each) do
        allow(ct).to receive(:identification).and_return('UNKNOWN-UNKNOWN')
        expect(CardTerminals::RMI::Null).to receive(:new).and_return(null)
      end

      it { expect(subject.supported?).to be_falsey }
      it { expect(subject.rmi_port).to eq(443) }

      [:reboot, :get_info, :get_idle_message, :remote_pairing].each do |action|
        describe "##{action}" do
          let(:res) { Result.new(false, 'Failure Message') }
          it "executes callback" do
            called_back = false
            subject.send(action) do |result|
              result.on_unsupported do |message|
                called_back = true
              end
            end
            expect(called_back).to be_truthy
          end
        end
      end

      describe "#set_idle_message" do
        let(:res) { Result.new(false, 'Failure Message') }
        it "executes callback" do
          called_back = false
          subject.set_idle_message("some text") do |result|
            result.on_unsupported do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end
    end

    ### Orga6141 v3.9.0 ##################################################
    describe "with Orga6141 v3.9.0" do
      let(:orgav1) do
        instance_double(CardTerminals::RMI::OrgaV1, 
          supported?: true, 
          rmi_port: 443,
          available_actions: [:reboot, :get_info, :get_idle_message, 
                              :set_idle_message, :verify_pin]
        )
      end
      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive(:identification).and_return('INGHC-ORGA6100')
        expect(CardTerminals::RMI::OrgaV1).to receive(:new).and_return(orgav1)
      end

      it { expect(subject.supported?).to be_truthy }
      it { expect(subject.rmi_port).to eq(443) }
 
      describe "#reboot" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:reboot).and_return(res)
          called_back = false
          subject.reboot do |result|
            result.on_success do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "#get_info" do
        let(:info) do
          CardTerminals::RMI::OrgaV1::Info.new({
            "rmi_smcb_pinEnabled" => true,
            "rmi_pairingEHealthTerminal_enabled" => true
          })
        end
        let(:res) { Result.new(true, 'Success Message', info) }
        it "executes callback" do
          expect(orgav1).to receive(:get_idle_message).and_return(res)
          called_back = false
          properties = nil
          subject.get_idle_message do |result|
            result.on_success do |message, value|
              called_back = true
              properties = value
            end
          end
          expect(called_back).to be_truthy
          expect(properties.remote_pin_enabled).to be_truthy
          expect(properties.remote_pairing_enabled).to be_truthy
        end
      end

      describe "#get_idle_message" do
        let(:res) { Result.new(true, 'Success Message', "X1234C") }
        it "executes callback" do
          expect(orgav1).to receive(:get_idle_message).and_return(res)
          called_back = false
          idle_message = nil
          subject.get_idle_message do |result|
            result.on_success do |message, value|
              called_back = true
              idle_message = value
            end
          end
          expect(called_back).to be_truthy
          expect(idle_message).to eq("X1234C")
        end
      end

      describe "#set_idle_message" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:set_idle_message).with(any_args).and_return(res)
          called_back = false
          # idle_message = nil
          subject.set_idle_message("testmsg") do |result|
            result.on_success do |message, value|
              called_back = true
              # idle_message = value
            end
          end
          expect(called_back).to be_truthy
          # expect(idle_message).to eq("X1234C")
        end
      end

      describe "#verify_pin" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:verify_pin).with(any_args).and_return(res)
          called_back = false
          subject.verify_pin("iccsn") do |result|
            result.on_success do |message, value|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "#remote_pairing" do
        let(:res) { Result.new(false, 'Not supported') }
        it "executes callback" do
          # expect(orgav1).to receive(:remote_pairing).and_return(res)
          called_back = false
          subject.remote_pairing do |result|
            result.on_unsupported do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end
    end

    ### Orga6141 v3.9.1 ##################################################
    describe "with Orga6141 v3.9.1" do
      let(:orgav1) do
        instance_double(CardTerminals::RMI::OrgaV1, 
          supported?: true, 
          rmi_port: 443,
          available_actions: [:reboot, :get_idle_message, :set_idle_message, :verify_pin, :remote_pairing]
        )
      end
      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.1')
        allow(ct).to receive(:identification).and_return('INGHC-ORGA6100')
        expect(CardTerminals::RMI::OrgaV1).to receive(:new).and_return(orgav1)
      end

      it { expect(subject.supported?).to be_truthy }
      it { expect(subject.rmi_port).to eq(443) }
 
      describe "#reboot" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:reboot).and_return(res)
          called_back = false
          subject.reboot do |result|
            result.on_success do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "#get_idle_message" do
        let(:res) { Result.new(true, 'Success Message', "X1234C") }
        it "executes callback" do
          expect(orgav1).to receive(:get_idle_message).and_return(res)
          called_back = false
          idle_message = nil
          subject.get_idle_message do |result|
            result.on_success do |message, value|
              called_back = true
              idle_message = value
            end
          end
          expect(called_back).to be_truthy
          expect(idle_message).to eq("X1234C")
        end
      end

      describe "#set_idle_message" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:set_idle_message).with(any_args).and_return(res)
          called_back = false
          # idle_message = nil
          subject.set_idle_message("testmsg") do |result|
            result.on_success do |message, value|
              called_back = true
              # idle_message = value
            end
          end
          expect(called_back).to be_truthy
          # expect(idle_message).to eq("X1234C")
        end
      end

      describe "#verify_pin" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:verify_pin).with(any_args).and_return(res)
          called_back = false
          subject.verify_pin("iccsn") do |result|
            result.on_success do |message, value|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "#remote_pairing" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(orgav1).to receive(:remote_pairing).and_return(res)
          called_back = false
          subject.remote_pairing do |result|
            result.on_success do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end
    end

  end
end
