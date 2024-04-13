require 'rails_helper'

RSpec.describe "clients/new", type: :view do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'clients' }
    allow(controller).to receive(:action_name) { 'new' }

    assign(:client, Client.new(
      name: "MyString",
      description: "MyString"
    ))
  end

  it "renders new client form" do
    render

    assert_select "form[action=?][method=?]", clients_path, "post" do

      assert_select "input[name=?]", "client[name]"

      assert_select "input[name=?]", "client[description]"
    end
  end
end
