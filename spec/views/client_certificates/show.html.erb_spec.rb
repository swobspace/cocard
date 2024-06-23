require 'rails_helper'

RSpec.describe "client_certificates/show", type: :view do
  before(:each) do
    assign(:client_certificate, ClientCertificate.create!(
      name: "Name",
      description: nil,
      cert: "MyText",
      pkey: "MyText",
      passphrase: "Passphrase"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Passphrase/)
  end
end
