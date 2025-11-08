require 'rails_helper'

RSpec.describe ClientCertificateConcerns, type: :model do
  let!(:cert1) do
    FactoryBot.create(:client_certificate, 
      name: 'myname',
      cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
      pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
      passphrase: 'justfortesting'
    )
  end

  describe "#to_text" do
    subject { cert1.to_text }
    it { expect(subject).to match('Subject: C=DE, L=Nirgendwo, O=Default Company Ltd, CN=intern') }
    it { expect(subject).to match('4d:b3:fc:a4:e7:b3:25:70:b5:ae:46:f0:cd:10:c4:28:66:29:9b:f7') }
    it { expect(subject).to match('sha256WithRSAEncryption') }
    it { expect(subject).to match('Not After : Nov  9 09:08:47 2051 GMT') }
    it { expect(subject).to match('Not Before: Jun 23 09:08:47 2024 GMT') }
  end

  describe "::active" do
    let(:cert2) { cert2 = cert1.dup; cert2.save; cert2 }
    before(:each) do
      cert2.update_column(:expiration_date, 1.day.before(Date.current))
    end

    it { expect(ClientCertificate.active).to contain_exactly(cert1) }
    it { expect(ClientCertificate.expired).to contain_exactly(cert2) }
  end

end
