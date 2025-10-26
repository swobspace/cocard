# frozen_string_literal: true

require 'rails_helper'
module KTProxies
  RSpec.describe Crupdator do
    let!(:tic) { FactoryBot.create(:ti_client) }
    let!(:ct1) { FactoryBot.create(:card_terminal, :with_mac) }
    let!(:ct2) { FactoryBot.create(:card_terminal, :with_mac, ip: "192.0.2.100") }

    let(:rise_ktp) {{
      "id"=>"e47789b6-ad96-11f0-ade2-c025a5b36994",
      "name"=>"ORGA6100-01234567890000",
      "wireguardIp"=>"203.0.113.7",
      "incomingIp"=>"198.51.100.1",
      "incomingPort"=>8123,
      "outgoingIp"=>"198.51.100.2",
      "outgoingPort"=>8123,
      "cardTerminalIp"=>"192.0.2.100",
      "cardTerminalPort"=>4742,
    }}

    subject { KTProxies::Crupdator.new(ti_client: tic, proxy_hash: rise_ktp) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(KTProxies::Crupdator) }
      it { expect(subject.respond_to?(:save)).to be_truthy }
    end

    describe '#new' do
      context 'without params' do
        it 'raises a KeyError' do
          expect do
            Crupdator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#save' do
      context 'without existing ktproxy' do
        it 'creates new ktproxy' do
          expect do
            subject.save
          end.to change(KTProxy, :count).by(1)
        end

        it 'creates a new ktproxy' do
          subject.save
          kt_proxy = subject.kt_proxy
          expect(kt_proxy.ti_client).to eq(tic)
          expect(kt_proxy.card_terminal).to eq(ct2)
          expect(kt_proxy.uuid).to eq("e47789b6-ad96-11f0-ade2-c025a5b36994")
          expect(kt_proxy.name).to eq("ORGA6100-01234567890000")
          expect(kt_proxy.wireguard_ip).to eq("203.0.113.7")
          expect(kt_proxy.incoming_ip).to eq("198.51.100.1")
          expect(kt_proxy.incoming_port).to eq(8123)
          expect(kt_proxy.outgoing_ip).to eq("198.51.100.2")
          expect(kt_proxy.outgoing_port).to eq(8123)
          expect(kt_proxy.card_terminal_ip).to eq("192.0.2.100")
          expect(kt_proxy.card_terminal_port).to eq(4742)
        end
      end

      context "with kt_proxy and matching uuid" do
        let!(:kt_proxy) do
          FactoryBot.create(:kt_proxy, 
            card_terminal_id: ct1.id,
            ti_client_id: tic.id,
            uuid: 'e47789b6-ad96-11f0-ade2-c025a5b36994'
          )
        end

        it 'does not create a kt_proxy' do
          expect do
            subject.save
          end.to change(KTProxy, :count).by(0)
        end

        it 'updates attributes' do
          subject.save
          kt_proxy = subject.kt_proxy
          expect(kt_proxy.ti_client).to eq(tic)
          expect(kt_proxy.card_terminal).to eq(ct2)
          expect(kt_proxy.uuid).to eq("e47789b6-ad96-11f0-ade2-c025a5b36994")
          expect(kt_proxy.name).to eq("ORGA6100-01234567890000")
          expect(kt_proxy.wireguard_ip).to eq("203.0.113.7")
          expect(kt_proxy.incoming_ip).to eq("198.51.100.1")
          expect(kt_proxy.incoming_port).to eq(8123)
          expect(kt_proxy.outgoing_ip).to eq("198.51.100.2")
          expect(kt_proxy.outgoing_port).to eq(8123)
          expect(kt_proxy.card_terminal_ip).to eq("192.0.2.100")
          expect(kt_proxy.card_terminal_port).to eq(4742)
        end
      end

      context "with kt_proxy and matching name/ip" do
        let!(:kt_proxy) do
          FactoryBot.create(:kt_proxy, 
            card_terminal_id: ct1.id,
            ti_client_id: tic.id,
            name: "ORGA6100-01234567890000",
            card_terminal_ip: '192.0.2.100'
          )
        end

        it 'does not create a kt_proxy' do
          expect do
            subject.save
          end.to change(KTProxy, :count).by(0)
        end

        it 'updates attributes' do
          subject.save
          kt_proxy = subject.kt_proxy
          expect(kt_proxy.ti_client).to eq(tic)
          expect(kt_proxy.card_terminal).to eq(ct2)
          expect(kt_proxy.uuid).to eq("e47789b6-ad96-11f0-ade2-c025a5b36994")
          expect(kt_proxy.name).to eq("ORGA6100-01234567890000")
          expect(kt_proxy.wireguard_ip).to eq("203.0.113.7")
          expect(kt_proxy.incoming_ip).to eq("198.51.100.1")
          expect(kt_proxy.incoming_port).to eq(8123)
          expect(kt_proxy.outgoing_ip).to eq("198.51.100.2")
          expect(kt_proxy.outgoing_port).to eq(8123)
          expect(kt_proxy.card_terminal_ip).to eq("192.0.2.100")
          expect(kt_proxy.card_terminal_port).to eq(4742)
        end
      end

      context "with kt_proxy and matching ip" do
        let!(:kt_proxy) do
          FactoryBot.create(:kt_proxy, 
            card_terminal_id: ct2.id,
            ti_client_id: tic.id,
            card_terminal_ip: '192.0.2.100'
          )
        end

        it 'does not create a kt_proxy' do
          expect do
            subject.save
          end.to change(KTProxy, :count).by(0)
        end

        it 'updates attributes' do
          subject.save
          kt_proxy = subject.kt_proxy
          expect(kt_proxy.ti_client).to eq(tic)
          expect(kt_proxy.card_terminal).to eq(ct2)
          expect(kt_proxy.uuid).to eq("e47789b6-ad96-11f0-ade2-c025a5b36994")
          expect(kt_proxy.name).to eq("ORGA6100-01234567890000")
          expect(kt_proxy.wireguard_ip).to eq("203.0.113.7")
          expect(kt_proxy.incoming_ip).to eq("198.51.100.1")
          expect(kt_proxy.incoming_port).to eq(8123)
          expect(kt_proxy.outgoing_ip).to eq("198.51.100.2")
          expect(kt_proxy.outgoing_port).to eq(8123)
          expect(kt_proxy.card_terminal_ip).to eq("192.0.2.100")
          expect(kt_proxy.card_terminal_port).to eq(4742)
        end
      end

      context "with kt_proxy, no card terminal and matching ip" do
        let!(:kt_proxy) do
          FactoryBot.create(:kt_proxy, 
            ti_client_id: tic.id,
            card_terminal_ip: '192.0.2.100'
          )
        end

        it 'does not create a kt_proxy' do
          expect do
            subject.save
          end.to change(KTProxy, :count).by(0)
        end

        it 'updates attributes' do
          subject.save
          kt_proxy = subject.kt_proxy
          expect(kt_proxy.ti_client).to eq(tic)
          expect(kt_proxy.card_terminal).to eq(ct2)
          expect(kt_proxy.uuid).to eq("e47789b6-ad96-11f0-ade2-c025a5b36994")
          expect(kt_proxy.name).to eq("ORGA6100-01234567890000")
          expect(kt_proxy.wireguard_ip).to eq("203.0.113.7")
          expect(kt_proxy.incoming_ip).to eq("198.51.100.1")
          expect(kt_proxy.incoming_port).to eq(8123)
          expect(kt_proxy.outgoing_ip).to eq("198.51.100.2")
          expect(kt_proxy.outgoing_port).to eq(8123)
          expect(kt_proxy.card_terminal_ip).to eq("192.0.2.100")
          expect(kt_proxy.card_terminal_port).to eq(4742)
        end
      end
    end
  end
end
