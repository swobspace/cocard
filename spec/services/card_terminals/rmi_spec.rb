# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe RMI do
    Result = Struct.new(:success?, :message)
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

    describe 'without valid product information' do
      it { expect(subject.supported?).to be_falsey }
      it { expect(subject.available_actions).to be_empty }
    end

    describe 'with valid product information' do
      let(:orgav1) do
        instance_double(CardTerminals::RMI::OrgaV1, 
          supported?: true, 
          rmi_port: 443,
          available_actions: [:reboot]
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
            end
          end
        end
      end
    end

  end
end
