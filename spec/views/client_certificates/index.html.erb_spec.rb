require 'rails_helper'

RSpec.describe "client_certificates/index", type: :view do
  before(:each) do
    assign(:client_certificates, [
      ClientCertificate.create!(
        name: "Name",
        description: nil,
        cert: "MyText",
        pkey: "MyText",
        passphrase: "Passphrase"
      ),
      ClientCertificate.create!(
        name: "Name",
        description: nil,
        cert: "MyText",
        pkey: "MyText",
        passphrase: "Passphrase"
      )
    ])
  end

  it "renders a list of client_certificates" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Passphrase".to_s), count: 2
  end
end
