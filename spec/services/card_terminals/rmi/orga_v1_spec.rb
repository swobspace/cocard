# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe RMI::OrgaV1 do
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
  
    subject { CardTerminals::RMI::OrgaV1.new(card_terminal: ct) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(CardTerminals::RMI::OrgaV1) }
      it { expect(subject).to be_kind_of(CardTerminals::RMI::Base) }
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
            RMI::OrgaV1.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe 'without valid product information' do
      it { expect(subject.supported?).to be_falsey }
    end

    describe 'with valid product information' do
      before(:each) do
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive(:firmware_version).and_return('3.9.0')
        allow(ct).to receive(:identification).and_return('INGHC-ORGA6100')
        ct.update(pin_mode: 'on_demand')
        ct.reload
      end
      it { expect(subject.supported?).to be_truthy }

      describe "#get_idle_message", :rmi => true do
        it "fetch idle message" do
          result = subject.get_idle_message
          expect(result.success?).to be_truthy
          expect(result.value).to eq('K03 0B692')
        end
      end

      describe "#get_properties", :rmi => true do
        it "returns properties" do
          result = subject.get_properties(%w[rmi_sessionEnabled rmi_timeout])
          expect(result.success?).to be_truthy
          expect(result.value).to include("rmi_sessionEnabled" => true,
                                                  "rmi_timeout" => 30)
        end
      end

      describe "#get_info", :rmi => true do
        it "returns info object" do
          result = subject.get_info
          expect(result.success?).to be_truthy
          expect(result.value).to be_kind_of CardTerminals::RMI::OrgaV1::Info
          expect(result.value.terminalname).to eq("ORGA6100-0241000000B692")
          expect(result.value.dhcp_enabled).to be_truthy
          expect(result.value.macaddr).to eq("000DF80C8652")
          expect(result.value.current_ip).to eq("10.200.149.235")
          expect(result.value.static_ip).to eq("192.168.1.1")
          expect(result.value.dhcp_ip).to eq("10.200.149.235")
          expect(result.value.remote_pin_enabled).to be_truthy
          expect(result.value.remote_pairing_enabled).to be_truthy
        end
      end


      describe "#verify_pin", :rmi2 => true do
        it "verifies pin" do
          result = subject.verify_pin(card.iccsn)
          expect(result.success?).to be_truthy
        end
      end

      describe "#set_idle_message", :rmi3 => true do
        it "set idle message" do
          result = subject.set_idle_message('Helau@\!%[]{}')
          expect(result.success?).to be_truthy

          result = subject.get_idle_message
          expect(result.success?).to be_truthy
          expect(result.value).to eq('Helau__!_____')
        end
      end

      describe "#reboot", :rmi4 => true do
        it "reboots terminal" do
          result = subject.reboot
          expect(result.success?).to be_truthy
          expect(result.message).to eq("Reboot initiated")
        end
      end
    end

  end
end
