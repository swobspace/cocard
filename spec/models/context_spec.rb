require 'rails_helper'

RSpec.describe Context, type: :model do
  let(:context) do 
    FactoryBot.create(:context, 
      mandant: 'ACME', 
      client_system: 'KIS',
      workplace: 'Konnektor'
    )
  end
  it { is_expected.to have_many(:connectors).through(:connector_contexts) }
  it { is_expected.to have_many(:cards).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of(:mandant) }
  it { is_expected.to validate_presence_of(:client_system) }
  it { is_expected.to validate_presence_of(:workplace) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:context)
    g = FactoryBot.create(:context)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:mandant).scoped_to([:client_system, :workplace])
    expect(f).to validate_uniqueness_of(:client_system).scoped_to([:mandant, :workplace])
    expect(f).to validate_uniqueness_of(:workplace).scoped_to([:client_system, :mandant])
  end

  describe "#to_s" do
    it { expect(context.to_s).to match('ACME - KIS - Konnektor') }
  end
end
