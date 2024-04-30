require 'rails_helper'

RSpec.describe CardTerminal, type: :model do
  let(:location) { FactoryBot.create(:location, lid: 'ACX') }
  let(:ct) do
    FactoryBot.create(:card_terminal,
      name: 'ACME Term',
      location: location,
    )
  end
  it { is_expected.to belong_to(:connector) }
  it { is_expected.to belong_to(:location).optional }

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_terminal)
    g = FactoryBot.create(:card_terminal)
    expect(f).to be_valid
    expect(g).to be_valid
    # expect(f).to validate_uniqueness_of(:mac)
  end

  describe "#to_s" do
    it { expect(ct.to_s).to match('ACME Term (ACX)') }
  end

  describe "on #save" do
    it "adds missing displayname" do
      ct.displayname = ''
      ct.name = "New Name"
      expect {
        ct.save 
      }.to change(ct, :displayname).to ('New Name')
    end
  end

end
