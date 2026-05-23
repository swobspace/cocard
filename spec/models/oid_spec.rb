require 'rails_helper'

RSpec.describe Oid, type: :model do
  let(:oid) { FactoryBot.create(:oid, oid: '1.2.3.4.5.6', name: 'Kuckuck') }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:oid) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:oid)
    g = FactoryBot.create(:oid)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:oid).case_insensitive
  end

  describe "#to_s" do
    it { expect(oid.to_s).to match("1.2.3.4.5.6 - Kuckuck") }
  end

  describe "#to_label" do
    it { expect(oid.to_label).to match("Kuckuck (1.2.3.4.5.6)") }
  end

end
