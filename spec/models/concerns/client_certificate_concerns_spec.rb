require 'rails_helper'

RSpec.describe ClientCertificateConcerns, type: :model do
  let(:client_certificate) do
    FactoryBot.create(:client_certificate, 
      name: 'myname',
      cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
      pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
      passphrase: 'justfortesting'
    )
  end
  describe "#to_text" do
    subject { client_certificate.to_text }
    it { expect(subject).to match('Subject: C=DE, L=Nirgendwo, O=Default Company Ltd, CN=intern') }
    it { expect(subject).to match('4d:b3:fc:a4:e7:b3:25:70:b5:ae:46:f0:cd:10:c4:28:66:29:9b:f7') }
    it { expect(subject).to match('sha256WithRSAEncryption') }
    it { expect(subject).to match('Not After : Nov  9 09:08:47 2051 GMT') }
    it { expect(subject).to match('Not Before: Jun 23 09:08:47 2024 GMT') }
  end
end
