require 'rails_helper'

RSpec.describe WorkplaceConcerns, type: :model do
  let(:wp) { FactoryBot.create(:workplace) }

  describe "#contexts" do
    let!(:twp1) do
      FactoryBot.create(:terminal_workplace,
        mandant: 'Mandy',
        client_system: 'SlowMed',
        workplace: wp
      )
    end
    let!(:twp2) do
      FactoryBot.create(:terminal_workplace,
        mandant: 'Mandy',
        client_system: 'FastMed',
        workplace: wp
      ) 
    end
    let!(:twp3) do
      FactoryBot.create(:terminal_workplace,
        mandant: 'Other',
        client_system: 'SlowMed',
        workplace: wp
      )
    end

    it { expect(wp.contexts).to contain_exactly("Mandy - SlowMed", "Mandy - FastMed", "Other - SlowMed") }
  end
end
