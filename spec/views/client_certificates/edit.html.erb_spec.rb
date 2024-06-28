require 'rails_helper'

RSpec.describe "client_certificates/edit", type: :view do
  let(:client_certificate) {
    FactoryBot.create(:client_certificate)
  }

  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'client_certificates' }
    allow(controller).to receive(:action_name) { 'edit' }

    assign(:client_certificate, client_certificate)
  end

  it "renders the edit client_certificate form" do
    render

    assert_select "form[action=?][method=?]", client_certificate_path(client_certificate), "post" do

      assert_select "input[name=?]", "client_certificate[name]"

      assert_select "input[name=?]", "client_certificate[description]"

      assert_select "textarea[name=?]", "client_certificate[cert]"

      assert_select "textarea[name=?]", "client_certificate[pkey]"

      assert_select "input[name=?]", "client_certificate[passphrase]"
    end
  end
end
