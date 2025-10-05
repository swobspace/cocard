# frozen_string_literal: true

require 'rails_helper'
module Connectors
  RSpec.describe RMI::Kocobox do
    Result = Struct.new(:success?, :message, :value, keyword_init: true)
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

    subject { Connectors::RMI::Kocobox.new(connector: connector) }
  
    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(Connectors::RMI::Kocobox) }
      it { expect(subject).to be_kind_of(Connectors::RMI::Base) }
      it { expect(subject.respond_to?(:available_actions)).to be_truthy }
      it { expect(subject.respond_to?(:reboot)).to be_truthy }
      it { expect(subject.respond_to?(:supported?)).to be_truthy }
    end

    describe '::new' do
      context 'without :connector' do
        it 'raises a KeyError' do
          expect do
            RMI::Kocobox.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe 'with connector type kocobox' do
      it { expect(subject.supported?).to be_truthy }

      #
      # does not a real reboot in test env
      #
      describe "#reboot with real credentials", :koco => true do
        it "starts a reboot" do
          result = subject.reboot
          expect(result.success?).to be_truthy
          expect(result.value).to eq(200)
          expect(connector.rebooted?).to be_truthy
        end
      end

      describe "#reboot with wrong credentials", :koco => true do
        it "does not succeed" do
          ENV['KOCO_ADMIN'] = 'none'
          ENV['KOCO_PASSWD'] = 'none'
          result = subject.reboot
          expect(result.success?).to be_falsey
          expect(connector.rebooted?).to be_falsey
        end
      end

      describe "#reboot without credentials" do
        it "does not succeed" do
          ENV['KOCO_ADMIN'] = nil
          ENV['KOCO_PASSWD'] = nil
          result = subject.reboot
          expect(result.success?).to be_falsey
          expect(result.message).to eq("Fehlende Zugangsdaten: KOCO_PASSWD oder KOCO_ADMIN nicht gesetzt")
          expect(connector.rebooted?).to be_falsey
        end
      end
    end

  end
end
