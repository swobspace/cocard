require 'rails_helper'

RSpec.describe "kt_proxies/show", type: :view do
  before(:each) do
    assign(:kt_proxy, KTProxy.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Uuid/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
    expect(rendered).to match(/4/)
  end
end
