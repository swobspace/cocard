require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { FactoryBot.create(:tag, name: 'Kuckuck') }
  it { is_expected.to have_many(:taggings).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:tag)
    g = FactoryBot.create(:tag)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:name).case_insensitive
  end

  describe "#to_s" do
    it { expect(tag.to_s).to match("Kuckuck") }
  end

end
