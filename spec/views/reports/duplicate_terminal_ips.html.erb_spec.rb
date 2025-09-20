require 'rails_helper'

RSpec.describe "reports/duplicate_terminal_ips.html.erb", type: :view do
  let(:ct1) { FactoryBot.create(:card_terminal, :with_mac, ip: '127.1.2.3') }
  let(:ct2) { FactoryBot.create(:card_terminal, :with_mac, ip: '127.1.2.3') }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'reports' }
    allow(controller).to receive(:action_name) { 'duplicate_terminal_ips' }

    @card_terminals = [ ct1, ct2 ]
    @duplicate_ips = [ '127.1.2.3' ]
  end

  it "renders a list of terminals with duplicate ips" do
    render
    expect(rendered).to have_content(ct1.name)
    expect(rendered).to have_content(ct2.name)
    expect(rendered).to have_content(ct1.mac)
    expect(rendered).to have_content(ct2.mac)
    expect(rendered).to have_content("Kartenterminal war noch nie online")
  end
end
