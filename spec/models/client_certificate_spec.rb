require 'rails_helper'

RSpec.describe ClientCertificate, type: :model do
  let(:client_certificate) do
    FactoryBot.create(:client_certificate, 
      name: 'myname',
      cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
      pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
      passphrase: 'justfortesting'
    )
  end
  it { is_expected.to have_and_belong_to_many(:connectors) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:cert) }
  it { is_expected.to validate_presence_of(:pkey) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:client_certificate)
    g = FactoryBot.create(:client_certificate)
    expect(f).to be_valid
    expect(g).to be_valid
  end

  describe "#to_s" do
    it { expect(client_certificate.to_s).to match('myname') }
  end

  describe "#client" do
    it { expect(client_certificate.client).to match('intern') }
  end

  describe "#certificate" do
    it { expect(client_certificate.certificate).to be_kind_of(OpenSSL::X509::Certificate) }
  end

  describe "#private_key" do
    it { expect(client_certificate.private_key).to be_kind_of(OpenSSL::PKey::RSA) }
  end

  describe "#valid_until" do
    it { expect(client_certificate.valid_until.localtime).to eq("2051-11-09 10:08:47 +0100") }
  end
end
