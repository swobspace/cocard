require 'rails_helper'

RSpec.describe CardCertificate, type: :model do
  let(:card_certificate) do
    FactoryBot.create(:card_certificate,
      cert_ref: 'C.AUT',
      subject_name: "CN=Some Stuff"
    )
  end

  it { is_expected.to belong_to(:card) }
  it { is_expected.to validate_presence_of(:cert_ref) }
  it { is_expected.to validate_inclusion_of(:cert_ref).in_array(CardCertificate::REF_TYPES) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_certificate)
    g = FactoryBot.create(:card_certificate)
    expect(f).to be_valid
    expect(g).to be_valid
    expect(f).to validate_uniqueness_of(:cert_ref).scoped_to(:card_id)
  end

  describe "#to_s" do
    it { expect(card_certificate.to_s).to match("CN=Some Stuff (C.AUT)") }
  end


end
