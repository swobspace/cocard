require 'rails_helper'

RSpec.describe SinglePicture, type: :model do
  let(:single_picture) do
    FactoryBot.create(:single_picture, 
      ci: 'CI-012345678',
      name: 'Some Service',
      organization: 'ACME Ltd'
    )
  end

  it 'should get plain factory working' do
    f = FactoryBot.create(:single_picture)
    g = FactoryBot.create(:single_picture)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:ci).case_insensitive
  end

  describe "#to_s" do
    it { expect(single_picture.to_s).to match('CI-012345678 - Some Service, ACME Ltd') }
  end

end
