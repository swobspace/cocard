require 'rails_helper'

RSpec.describe ConnectorContext, type: :model do
  it { is_expected.to belong_to(:connector) }
  it { is_expected.to belong_to(:context) }

  it { is_expected.to validate_presence_of(:connector_id) }
  it { is_expected.to validate_presence_of(:context_id) }


  it 'should get plain factory working' do
    f = FactoryBot.create(:connector_context)
    g = FactoryBot.create(:connector_context)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:context_id).scoped_to(:connector_id)
    expect(f).to validate_uniqueness_of(:connector_id).scoped_to(:context_id)
  end

end
