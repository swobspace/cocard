require 'rails_helper'

RSpec.describe "kt_proxies/index", type: :view do
  before(:each) do
    assign(:kt_proxies, [
      KTProxy.create!(
        card_terminal: nil,
        uuid: "Uuid",
        name: "Name",
        wireguard_ip: "",
        incoming_ip: "",
        incoming_port: 2,
        outgoing_ip: "",
        outgoing_port: 3,
        card_terminal_ip: "",
        card_terminal_port: 4
      ),
      KTProxy.create!(
        card_terminal: nil,
        uuid: "Uuid",
        name: "Name",
        wireguard_ip: "",
        incoming_ip: "",
        incoming_port: 2,
        outgoing_ip: "",
        outgoing_port: 3,
        card_terminal_ip: "",
        card_terminal_port: 4
      )
    ])
  end

  it "renders a list of kt_proxies" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Uuid".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(4.to_s), count: 2
  end
end
