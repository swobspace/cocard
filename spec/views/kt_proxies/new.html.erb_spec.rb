require 'rails_helper'

RSpec.describe "kt_proxies/new", type: :view do
  before(:each) do
    assign(:kt_proxy, KTProxy.new(
      card_terminal: nil,
      uuid: "MyString",
      name: "MyString",
      wireguard_ip: "",
      incoming_ip: "",
      incoming_port: 1,
      outgoing_ip: "",
      outgoing_port: 1,
      card_terminal_ip: "",
      card_terminal_port: 1
    ))
  end

  it "renders new kt_proxy form" do
    render

    assert_select "form[action=?][method=?]", kt_proxies_path, "post" do

      assert_select "input[name=?]", "kt_proxy[card_terminal_id]"

      assert_select "input[name=?]", "kt_proxy[uuid]"

      assert_select "input[name=?]", "kt_proxy[name]"

      assert_select "input[name=?]", "kt_proxy[wireguard_ip]"

      assert_select "input[name=?]", "kt_proxy[incoming_ip]"

      assert_select "input[name=?]", "kt_proxy[incoming_port]"

      assert_select "input[name=?]", "kt_proxy[outgoing_ip]"

      assert_select "input[name=?]", "kt_proxy[outgoing_port]"

      assert_select "input[name=?]", "kt_proxy[card_terminal_ip]"

      assert_select "input[name=?]", "kt_proxy[card_terminal_port]"
    end
  end
end
