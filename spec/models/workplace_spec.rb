require 'rails_helper'

RSpec.describe Workplace, type: :model do
  let(:wp) { FactoryBot.create(:workplace, name: 'NB-AXC-0004') }

  it { is_expected.to have_many(:card_terminals).through(:terminal_workplaces) }
  it { is_expected.to have_many(:terminal_workplaces).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:workplace)
    g = FactoryBot.create(:workplace)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:name).case_insensitive
  end

  describe "#to_s" do
    it { expect(wp.to_s).to match('NB-AXC-0004') }
  end

end
