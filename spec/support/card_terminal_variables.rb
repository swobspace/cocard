shared_context "card_terminal variables" do
  let(:tag) { FactoryBot.create(:tag, name: 'MyTag') }
  let(:ts)  { Time.parse("2025-03-11 12:00:00") }
  let(:ber) { FactoryBot.create(:location, lid: 'BER') }
  let(:network) { FactoryBot.create(:network, netzwerk: '127.51.0.0/16', location: ber) }
  let(:conn) { FactoryBot.create(:connector, name: 'TIK-127') }
  let(:card) do
    FactoryBot.create(:card, 
      card_type: 'SMC-KT', 
      iccsn: '802761234567',
      expiration_date: '2025-11-27',
    )
  end
  let!(:ct1) do
    FactoryBot.create(:card_terminal, :with_mac,
      displayname: 'KLG ct1',
      ct_id: 'CT_ID_0001',
      name: 'KLG-AXC-17',
      description: "some more infos",
      ip: '127.51.100.17',
      current_ip: '127.51.100.17',
      condition: 0,
      condition_message: "Condition Message",
      idle_message: "Willkommen!",
      connected: true,
      firmware_version: '5.3.4',
      location: ber,
      supplier: 'ACME Ltd. International',
      delivery_date: '2020-03-01',
      last_ok: ts,
      network: network,
      pin_mode: :on_demand,
    )
  end

  let!(:ct2) do
    FactoryBot.create(:card_terminal,
      displayname: 'KLG ct2',
      name: 'KLG-CWZ-04',
      ip: '127.203.113.4',
      current_ip: '127.203.113.4',
      idle_message: "Willkommen!",
      ct_id: 'CT_ID_0124',
      condition: 2,
      firmware_version: '4.9.3',
      serial: 'SERIAL12345',
      id_product: 'IdProduct',
      mac: '11:22:33:44:55:66',
      supplier: 'ACME Ltd. International',
      connector: conn,
      connected: true,
      last_ok: ts - 1.week,
      network: network,
      pin_mode: :on_demand,
      delivery_date: '2020-03-07',
    )
  end

  let!(:ct3) do
    FactoryBot.create(:card_terminal, :with_mac,
      displayname: 'KLG ct3',
      ct_id: 'CT_ID_0003',
      name: 'KLG-CWZ-05',
      ip: '127.50.100.5',
      current_ip: '127.50.100.5',
      condition: 3,
      firmware_version: '4.9.3',
      room: 'U.16',
      contact: 'Dr.Who',
      plugged_in: 'Switch 17/4',
      supplier: 'ACME Ltd. International',
      last_ok: ts - 1.month,
      last_check: Time.current,
      network: network,
      connector: conn,
    )
  end

  let!(:card_slot) do
    FactoryBot.create(:card_terminal_slot, 
      slotid: 4,
      card: card,
      card_terminal: ct2
    )
  end
end
