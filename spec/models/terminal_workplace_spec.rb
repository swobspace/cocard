require 'rails_helper'

RSpec.describe TerminalWorkplace, type: :model do
  it { is_expected.to belong_to(:card_terminal) }
  it { is_expected.to belong_to(:workplace) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:terminal_workplace)
    g = FactoryBot.create(:terminal_workplace)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:workplace_id)
                 .scoped_to([:card_terminal_id, :mandant, :client_system])
    expect(f).to validate_uniqueness_of(:card_terminal_id)
                 .scoped_to([:workplace_id, :mandant, :client_system])
  end

end
