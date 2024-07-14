require 'rails_helper'

RSpec.describe CardContext, type: :model do
  it { is_expected.to belong_to(:card).optional }
  it { is_expected.to belong_to(:context) }

  it { is_expected.to validate_presence_of(:card_id) }
  it { is_expected.to validate_presence_of(:context_id) }


  it 'should get plain factory working' do
    f = FactoryBot.create(:card_context)
    g = FactoryBot.create(:card_context)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:context_id).scoped_to(:card_id)
    expect(f).to validate_uniqueness_of(:card_id).scoped_to(:context_id)
  end
end
