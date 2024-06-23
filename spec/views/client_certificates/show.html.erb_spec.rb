require 'rails_helper'

RSpec.describe "client_certificates/show", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'client_certificates' }
    allow(controller).to receive(:action_name) { 'show' }

    assign(:client_certificate, ClientCertificate.create!(
      name: "Cert 2",
      description: "some information",
      cert: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-cert.pem')),
      pkey: File.read(File.join(Rails.root, 'spec/fixtures/files', 'demo-pkey.pem')),
      passphrase: 'justfortesting'
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Cert 2/)
    expect(rendered).to match(/some information/)
    expect(rendered).to match(/BEGIN CERTIFICATE/)
    expect(rendered).to match(/BEGIN ENCRYPTED PRIVATE KEY/)
    expect(rendered).to match(/2051-11-09 10:08:47 .0100/)
    expect(rendered).to match(/\*\*\*\*\*\*\*\*\*\*\*\*/)
  end
end
