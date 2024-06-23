require 'rails_helper'

RSpec.describe "client_certificates/new", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'client_certificates' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:client_certificate, ClientCertificate.new(
      name: "MyString",
      description: nil,
      cert: "MyText",
      pkey: "MyText",
      passphrase: "MyString"
    ))
  end

  it "renders new client_certificate form" do
    render

    assert_select "form[action=?][method=?]", client_certificates_path, "post" do

      assert_select "input[name=?]", "client_certificate[name]"

      assert_select "input[name=?]", "client_certificate[description]"

      assert_select "textarea[name=?]", "client_certificate[cert]"

      assert_select "textarea[name=?]", "client_certificate[pkey]"

      assert_select "input[name=?]", "client_certificate[passphrase]"
    end
  end
end
