require 'rails_helper'
RSpec.describe OperationalState, type: :model do
  let(:operational_state) { FactoryBot.create(:operational_state, name: 'im Schrank') }
  it { is_expected.to have_many(:cards) }
  it { is_expected.to validate_presence_of(:name) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:operational_state)
    g = FactoryBot.create(:operational_state)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:name).case_insensitive
  end

  describe "#to_s" do
    it { expect(operational_state.to_s).to match('im Schrank') }
  end
end
