require 'rails_helper'

RSpec.describe "client_certificates/index", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'client_certificates' }
    allow(controller).to receive(:action_name) { 'index' }

    assign(:client_certificates, [
      ClientCertificate.create!(
        name: "Cert 1",
        description: "some information",
        cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
        pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
        passphrase: 'justfortesting'

      ),
      ClientCertificate.create!(
        name: "Cert 2",
        description: "some information",
        cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
        pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
        passphrase: 'justfortesting'
      )
    ])
  end

  it "renders a list of client_certificates" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("Cert 1".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("Cert 2".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("some information".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("intern".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("2051-11-09 10:08:47 .0100".to_s), count: 2
  end
end
