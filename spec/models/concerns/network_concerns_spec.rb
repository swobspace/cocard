require 'rails_helper'

RSpec.describe NetworkConcerns, type: :model do
  let(:network) do
    FactoryBot.create(:network, 
      netzwerk: '192.0.2.32/28'
    )
  end

  describe "#to_cidr_s" do
    it { expect(network.to_cidr_s).to eq('192.0.2.32/28') }
  end

end
