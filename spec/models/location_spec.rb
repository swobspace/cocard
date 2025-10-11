require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { FactoryBot.create(:location, lid: 'BER') }
  it { is_expected.to have_and_belong_to_many(:connectors) }
  it { is_expected.to have_many(:networks).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:cards).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:card_terminals).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:tags).through(:taggings) }
  it { is_expected.to validate_presence_of(:lid) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:location)
    g = FactoryBot.create(:location)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:lid).case_insensitive
  end

  describe "#to_s" do
    it { expect(location.to_s).to match('BER') }
  end

  describe "Taggable" do
    before(:each) do
      location.tag_list = %w[ Eins Zwei ]
      location.reload
    end
  
    it { expect(location.tag_list).to contain_exactly('Eins', 'Zwei') }
  
    it "doesn't delete tags on save" do
      expect {
        location.update(updated_at: Time.current)
      }.not_to change(location, :tag_list)
    end
  end

end
