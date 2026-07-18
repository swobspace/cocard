# frozen_string_literal: true

require 'rails_helper'

module CardTerminals
  class RMI
    RSpec.describe Creator do
      describe '#save with Cherry ST-1506 info' do
        let(:info) do
          CherryV1::Info.new(
            'providerId' => 'DECHY',
            'productShortName' => 'ST1506',
            'deviceName' => 'Cherry ST-1506',
            'ethernetMacAddress' => 'aa:bb:cc:dd:ee:ff',
            'ipAddress' => '192.0.2.10',
            'fwVersion' => '3.2.1',
            'smcktSerialNumber' => 'CHERRY-SERIAL-123',
            'smcktProductTypeVersion' => '2.0',
            'smcktPersonalization' => 'RSA,ECC',
            'smcktExpirationDateAUT' => '20270131',
            'smcktExpirationDateAUT2' => '20280229'
          )
        end

        it 'exposes Creator capability methods for Cherry-specific get_info behavior' do
          expect(info.preserve_nil_terminal_attributes?).to be(true)
          expect(info.missing_smckt_card_is_success?).to be(true)
        end

        it 'updates terminal fields but does not create or link an SMC-KT card without reliable ICCSN and slot' do
          creator = described_class.new(info: info)

          expect { @save_result = creator.save }.to change(CardTerminal, :count).by(1)
            .and change(Card, :count).by(0)
            .and change(CardTerminalSlot, :count).by(0)

          expect(@save_result).to be_truthy

          terminal = creator.card_terminal.reload
          expect(terminal.mac).to eq('AABBCCDDEEFF')
          expect(terminal.ip).to eq('192.0.2.10')
          expect(terminal.name).to eq('Cherry ST-1506')
          expect(terminal.identification).to eq('DECHY-ST1506')
          expect(terminal.firmware_version).to eq('3.2.1')
        end

        it 'preserves existing values for Cherry fields that are not exposed while updating provided fields' do
          terminal = FactoryBot.create(
            :card_terminal,
            mac: 'AABBCCDDEEFF',
            ip: '198.51.100.1',
            name: 'Old terminal name',
            identification: 'OLD-ID',
            firmware_version: '1.0.0',
            serial: 'EXISTING-SERIAL',
            uptime_total: 1234,
            uptime_reboot: 56,
            slot1_plug_cycles: 11,
            slot2_plug_cycles: 22,
            slot3_plug_cycles: 33,
            slot4_plug_cycles: 44
          )

          allow(info).to receive(:slot1_plug_cycles).and_return(0)
          creator = described_class.new(info: info)

          expect(creator.save).to be_truthy

          terminal.reload
          expect(terminal.ip).to eq('192.0.2.10')
          expect(terminal.name).to eq('Cherry ST-1506')
          expect(terminal.identification).to eq('DECHY-ST1506')
          expect(terminal.firmware_version).to eq('3.2.1')
          expect(terminal.serial).to eq('EXISTING-SERIAL')
          expect(terminal.uptime_total).to eq(1234)
          expect(terminal.uptime_reboot).to eq(56)
          expect(terminal.slot1_plug_cycles).to eq(11)
          expect(terminal.slot2_plug_cycles).to eq(22)
          expect(terminal.slot3_plug_cycles).to eq(33)
          expect(terminal.slot4_plug_cycles).to eq(44)
        end
      end

      describe '#save with ORGA info' do
        let(:orga_properties) do
          {
            'net_lan_macAddr' => '00:11:22:33:44:aa',
            'sys_terminalName' => 'ORGA-6100-Terminalname',
            'net_lan_ipAddr' => '127.1.2.3',
            'vendor_serialNumber' => 'SERIAL1234',
            'sys_firmwareVersion' => '4.9.0',
            'sys_uptime_durationTotal' => '340',
            'sys_uptime_durationSinceBoot' => '12',
            'card_slot1_plugCycles' => '101',
            'card_slot2_plugCycles' => '102',
            'card_slot3_plugCycles' => '103',
            'card_slot4_plugCycles' => '104',
            'vendor_deviceManufacturerId' => 'INGHC',
            'vendor_deviceModelName' => 'ORGA6100',
            'card_smkt_iccsn' => '80276123456789011111',
            'card_smkt_version' => '4.4.1',
            'card_smkt_slotNum' => smckt_slot,
            'card_smkt_autType' => 'RSA',
            'card_smkt_autCxd' => '11.11.2026',
            'card_smkt_aut2Type' => 'ECC',
            'card_smkt_aut2Cxd' => '30.08.2030'
          }
        end
        let(:smckt_slot) { 4 }
        let(:info) { OrgaV1::Info.new(orga_properties) }

        it 'relies on Creator-local defaults when ORGA info has no Cherry-specific hooks' do
          expect(info).not_to respond_to(:preserve_nil_terminal_attributes?)
          expect(info).not_to respond_to(:missing_smckt_card_is_success?)
        end

        it 'creates and links an SMC-KT card for a positive slot and returns true' do
          creator = described_class.new(info: info)

          expect { @save_result = creator.save }.to change(CardTerminal, :count).by(1)
            .and change(Card, :count).by(1)
            .and change(CardTerminalSlot, :count).by(1)

          expect(@save_result).to be_truthy

          card = Card.find_by!(iccsn: '80276123456789011111')
          slot = CardTerminalSlot.find_by!(card_terminal_id: creator.card_terminal.id, slotid: 4)
          expect(card.card_type).to eq('SMC-KT')
          expect(card.expiration_date).to eq(Date.new(2030, 8, 30))
          expect(card.card_terminal_slot).to eq(slot)
        end


        it 'does not preserve existing terminal values when ORGA reports nil fields' do
          terminal = FactoryBot.create(
            :card_terminal,
            mac: '0011223344AA',
            serial: 'EXISTING-SERIAL',
            uptime_total: 1234
          )
          orga_properties['vendor_serialNumber'] = nil
          orga_properties['sys_uptime_durationTotal'] = nil

          expect(described_class.new(info: info).save).to be_truthy

          terminal.reload
          expect(terminal.serial).to be_nil
          expect(terminal.uptime_total).to be_nil
        end

        it 'does not rewrite card type or expiration date for an existing card with the same ICCSN' do
          existing_card = FactoryBot.create(
            :card,
            iccsn: '80276123456789011111',
            card_type: 'SMC-B',
            expiration_date: Date.new(2025, 1, 31)
          )

          expect(described_class.new(info: info).save).to be_truthy

          existing_card.reload
          expect(existing_card.card_type).to eq('SMC-B')
          expect(existing_card.expiration_date).to eq(Date.new(2025, 1, 31))
          expect(existing_card.card_terminal_slot.slotid).to eq(4)
        end


        it 'clears an older card occupying the target slot before linking the current card' do
          terminal = FactoryBot.create(:card_terminal, mac: '0011223344AA')
          slot = FactoryBot.create(:card_terminal_slot, card_terminal: terminal, slotid: 4)
          old_card = FactoryBot.create(:card, iccsn: '80276123456789000000', card_terminal_slot: slot)

          expect(described_class.new(info: info).save).to be_truthy

          expect(old_card.reload.card_terminal_slot).to be_nil
          expect(Card.find_by!(iccsn: '80276123456789011111').card_terminal_slot).to eq(slot)
        end

      end
    end
  end
end
