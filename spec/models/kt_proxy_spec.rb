require 'rails_helper'

RSpec.describe KTProxy, type: :model do
  it { is_expected.to belong_to(:card_terminal).optional }
  it { is_expected.to validate_presence_of(:uuid) }
  it { is_expected.to validate_presence_of(:card_terminal_ip) }
  it { is_expected.to validate_presence_of(:wireguard_ip) }
  it { is_expected.to validate_presence_of(:incoming_ip) }
  it { is_expected.to validate_presence_of(:outgoing_port) }
  it { is_expected.to validate_presence_of(:incoming_ip) }
  it { is_expected.to validate_presence_of(:outgoing_port) }
  

  it 'should get plain factory working' do
    f = FactoryBot.create(:kt_proxy)
    g = FactoryBot.create(:kt_proxy)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:uuid)
    expect(f).to validate_uniqueness_of(:card_terminal_ip)
    expect(f).to validate_uniqueness_of(:incoming_port)
    expect(f).to validate_uniqueness_of(:outgoing_port)
  end

end
