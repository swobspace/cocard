# frozen_string_literal: true

require 'rails_helper'
module Connectors
  RSpec.describe RMI do
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

    describe "with kocobox" do
      describe "#rmi" do
        it { expect(subject.rmi).to be_kind_of(Connectors::RMI::Kocobox) }
      end

      describe "#rmi.reboot" do
        it { expect(subject.rmi).to respond_to(:reboot) }
      end

      describe "#available_actions" do
        it { expect(subject.available_actions).to contain_exactly(:reboot) }
      end

      #
      # does not a real reboot in test env
      #
      describe "#call(:reboot) with real credentials", :koco => true do
        it "starts a reboot" do
          result = subject.call(:reboot)
          expect(result.success?).to be_truthy
          expect(result.response.status).to eq(200)
          puts result.response.headers
          puts result.response.body
        end
      end

      describe "#call(:reboot) with wrong credentials", :koco => true do
        it "does not succeed" do
          ENV['KOCO_ADMIN'] = 'none'
          ENV['KOCO_PASSWD'] = 'none'
          result = subject.call(:reboot)
          expect(result.success?).to be_falsey
        end
      end

      describe "#call(:reboot) without credentials" do
        it "does not succeed" do
          ENV['KOCO_ADMIN'] = nil
          ENV['KOCO_PASSWD'] = nil
          result = subject.call(:reboot)
          expect(result.success?).to be_falsey
          expect(result.response).to eq("Fehlende Zugangsdaten: KOCO_PASSWD oder KOCO_ADMIN nicht gesetzt")
        end
      end
    end

    describe "with unknown connector type" do
      let(:connector) { FactoryBot.create(:connector) }
      describe "#rmi" do
        it { expect(subject.rmi).to be_kind_of(Connectors::RMI::Null) }
      end

      describe "#available_actions" do
        it { expect(subject.available_actions).to contain_exactly() }
      end
    end
    
  end
end
