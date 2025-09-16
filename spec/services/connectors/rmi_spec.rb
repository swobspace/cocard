# frozen_string_literal: true

require 'rails_helper'
module Connectors
  RSpec.describe RMI do
    Result = Struct.new(:success?, :message, :value)
    #
    # connector
    #
    let(:connector_yml) do
      File.join(Rails.root, 'spec', 'fixtures', 'files', 'connector_services.yaml')
    end
    let(:connector) do
      FactoryBot.create(:connector,
        ip: ENV['KOCO_IP'],
        connector_services: YAML.load_file(connector_yml),
        vpnti_online: true
      )
    end

    subject { Connectors::RMI.new(connector: connector) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(Connectors::RMI) }
      it { expect(subject.respond_to?(:available_actions)).to be_truthy }
      it { expect(subject.respond_to?(:reboot)).to be_truthy }
      it { expect(subject.respond_to?(:supported?)).to be_truthy }
    end

    describe '::new' do
      context 'without :card_terminal' do
        it 'raises a KeyError' do
          expect do
            Connectors::RMI.new()
          end.to raise_error(KeyError)
        end
      end
    end

    ### UNKNOWN connector ##################################################
    describe "with unknown connector type" do
      let(:null) do
        instance_double(Connectors::RMI::Null,
          supported?: false,
          available_actions: []
        )
      end
      before(:each) do
        allow(connector).to receive(:identification).and_return('UNKNOWN-UNKNOWN')
        expect(Connectors::RMI::Null).to receive(:new).and_return(null)
      end

      it { expect(subject.supported?).to be_falsey }

      describe "#reboot" do
        let(:res) { Result.new(false, 'Failure Message') }
        it "executes callback" do
          called_back = false
          subject.reboot do |result|
            result.on_unsupported do |message|
              called_back = true
            end
          end
          expect(called_back).to be_truthy
        end
      end
    end

    ### KoCoBox ##################################################
    describe "with kocobox" do

      let(:koco) do
        instance_double(Connectors::RMI::Kocobox,
          supported?: true,
          available_actions: [:reboot]
        )
      end
      before(:each) do
        allow(connector).to receive(:identification).and_return('KOCOC-kocobox')
        expect(Connectors::RMI::Kocobox).to receive(:new).and_return(koco)
      end

      it { expect(subject.supported?).to be_truthy }

      describe "#reboot" do
        let(:res) { Result.new(true, 'Success Message') }
        it "executes callback" do
          expect(koco).to receive(:reboot).and_return(res)
          called_back = false
          subject.reboot do |result|
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
