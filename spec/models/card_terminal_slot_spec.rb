require 'rails_helper'

RSpec.describe CardTerminalSlot, type: :model do
  let(:ct) do
    FactoryBot.create(:card_terminal, :with_mac, 
      connector: connector,
      location: location,
      ip: '127.6.19.23'
    )
  end
  let(:card) do
    FactoryBot.create(:card, 
      card_holder_name: "Doctor Who's Universe",
      card_terminal: ct,
      expiration_date: 2.years.after(Date.current),
      updated_at: Time.current,
      operational_state: opsta,
      certificate: "some string"
    )
  end

  it { is_expected.to belong_to(:card_terminal) }
  it { is_expected.to belong_to(:card) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_terminal_slot)
    g = FactoryBot.create(:card_terminal_slot)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:slot).scoped_to(:card_terminal_id)
    expect(f).to validate_uniqueness_of(:card_id)
  end

end
