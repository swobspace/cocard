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

    it do
      expect(CardTerminals::RMI::SUPPORTED_IDENTIFICATIONS).to contain_exactly(
        'INGHC-ORGA6100', 'DECHY-ST1506', 'CHERRY-ST1506', 'CHERRY-ST-1506'
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
      it { expect(subject.respond_to?(:verify_pin_while)).to be_truthy }
      it { expect(subject.respond_to?(:coordinated_verify_pin_supported?)).to be_truthy }
      it { expect(subject.respond_to?(:coordinated_verify_pin_available?)).to be_truthy }
      it { expect(subject.respond_to?(:remote_pairing)).to be_truthy }
      it { expect(subject.respond_to?(:supported?)).to be_truthy }
    end

    describe "concrete coordinated verify policies" do
      let(:terminal) { instance_double(CardTerminal, firmware_version: '3.9.1') }

      it "CherryV1 advertises coordinated verify" do
        rmi = CardTerminals::RMI::CherryV1.new(card_terminal: terminal)

        expect(rmi.available_actions).to include(:verify_pin_while)
        expect(rmi.coordinated_verify_pin_supported?).to be_truthy
      end

      it "Base, Null, and ORGA do not opt into coordinated verify" do
        base = CardTerminals::RMI::Base.new(card_terminal: terminal)
        null = CardTerminals::RMI::Null.new(card_terminal: terminal)
        orga = CardTerminals::RMI::OrgaV1.new(card_terminal: terminal)

        [base, null, orga].each do |rmi|
          expect(rmi.available_actions).not_to include(:verify_pin_while)
          expect(rmi.coordinated_verify_pin_supported?).to be_falsey
        end
      end
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
          available_actions: [],
          coordinated_verify_pin_supported?: false,
        )
      end
      before(:each) do
        allow(ct).to receive(:identification).and_return('UNKNOWN-UNKNOWN')
        expect(CardTerminals::RMI::Null).to receive(:new).and_return(null)
      end

      it { expect(subject.supported?).to be_falsey }
      it { expect(subject.rmi_port).to eq(443) }
      it { expect(subject.coordinated_verify_pin_supported?).to be_falsey }

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

    ### Cherry ST-1506 ####################################################
    describe "with Cherry ST-1506" do
      let(:cherry_v1) do
        instance_double(CardTerminals::RMI::CherryV1,
          supported?: true,
          rmi_port: 443,
          available_actions: [:verify_pin, :verify_pin_while, :get_info],
          coordinated_verify_pin_supported?: true,
        )
      end

      before(:each) do
        allow(ct).to receive(:identification).and_return('CHERRY-ST-1506')
        expect(CardTerminals::RMI::CherryV1).to receive(:new).and_return(cherry_v1)
      end

      it { expect(subject.supported?).to be_truthy }
      it { expect(subject.rmi_port).to eq(443) }
      it { expect(subject.coordinated_verify_pin_supported?).to be_truthy }
      it { expect(subject.coordinated_verify_pin_available?).to be_truthy }

      context "when the connector reports DECHY-ST1506" do
        before(:each) do
          allow(ct).to receive(:identification).and_return('DECHY-ST1506')
        end

        it { expect(subject.supported?).to be_truthy }
      end

      describe "#verify_pin" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(cherry_v1).to receive(:verify_pin).with(any_args).and_return(res)
          called_back = false
          subject.verify_pin("iccsn") do |result|
            result.on_success do |message, value|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end

      describe "#verify_pin_while" do
        let(:block_result) { instance_double('VerifyPinResult') }
        let(:res) { Result.new(true, 'Success Message', block_result) }

        it "returns a success status with the block result" do
          expect(cherry_v1).to receive(:verify_pin_while).with('iccsn').and_yield.and_return(res)
          called_block = false

          status = subject.verify_pin_while('iccsn') { called_block = true }

          called_back = false
          value = nil
          status.on_success do |_message, returned_value|
            called_back = true
            value = returned_value
          end
          expect(called_block).to be_truthy
          expect(called_back).to be_truthy
          expect(value).to eq(block_result)
        end

        it "is unsupported when coordinated verify is not advertised as an available action" do
          allow(cherry_v1).to receive(:available_actions).and_return([:verify_pin, :get_info])
          expect(cherry_v1).not_to receive(:verify_pin_while)

          status = subject.verify_pin_while('iccsn')

          called_back = false
          status.on_unsupported { called_back = true }
          expect(called_back).to be_truthy
        end

        it "is unsupported when coordinated verify policy is disabled even if action is advertised" do
          allow(cherry_v1).to receive(:coordinated_verify_pin_supported?).and_return(false)
          allow(cherry_v1).to receive(:available_actions).and_return([:verify_pin, :verify_pin_while, :get_info])
          expect(cherry_v1).not_to receive(:verify_pin_while)

          status = subject.verify_pin_while('iccsn')

          called_back = false
          status.on_unsupported { called_back = true }
          expect(called_back).to be_truthy
        end
      end

      describe "#get_info" do
        let(:info) { instance_double(CardTerminals::RMI::CherryV1::Info) }
        let(:res) { Result.new(true, 'Success Message', info) }

        it "executes callback" do
          expect(cherry_v1).to receive(:get_info).and_return(res)
          called_back = false
          returned_info = nil
          subject.get_info do |result|
            result.on_success do |message, value|
              called_back = true
              returned_info = value
            end
          end
          expect(called_back).to be_truthy
          expect(returned_info).to eq(info)
        end
      end

      describe "#reboot" do
        it "is unsupported" do
          called_back = false
          subject.reboot do |result|
            result.on_unsupported { called_back = true }
          end
          expect(called_back).to be_truthy
        end
      end
    end

    describe "with Cherry ST-1506 product name metadata" do
      let(:cherry_v1) do
        instance_double(CardTerminals::RMI::CherryV1,
          supported?: true,
          rmi_port: 443,
          available_actions: [:verify_pin, :verify_pin_while, :get_info],
          coordinated_verify_pin_supported?: true,
        )
      end

      before(:each) do
        allow(ct).to receive(:identification).and_return('UNKNOWN')
        product_information = instance_double('ProductInformation',
          product_code: nil,
          product_miscellaneous: { product_name: 'Cherry ST-1506' }
        )
        allow(ct).to receive(:product_information).and_return(product_information)
        expect(CardTerminals::RMI::CherryV1).to receive(:new).and_return(cherry_v1)
      end

      it { expect(subject.supported?).to be_truthy }
    end

    ### Orga6141 v3.9.0 ##################################################
    describe "with Orga6141 v3.9.0" do
      let(:orgav1) do
        instance_double(CardTerminals::RMI::OrgaV1, 
          supported?: true, 
          rmi_port: 443,
          available_actions: [:reboot, :get_info, :get_idle_message, 
                              :set_idle_message, :verify_pin],
          coordinated_verify_pin_supported?: false,
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
          available_actions: [:reboot, :get_idle_message, :set_idle_message, :verify_pin, :remote_pairing],
          coordinated_verify_pin_supported?: false,
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
