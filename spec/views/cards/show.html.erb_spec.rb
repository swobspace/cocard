require 'rails_helper'

RSpec.describe "cards/show", type: :view do
  let(:ct) { FactoryBot.create(:card_terminal, ct_id: 'CT_ID_0176') }
  let(:ts) { Time.current }
  before(:each) do
    assign(:card, Card.create!(
      card_terminal_id: ct.id,
      name: "GemaCard",
      description: "some other text",
      card_handle: "7fb65ede-0a37-11ef-8f85-c025a5b36994",
      card_type: "SMB-C",
      iccsn: "8027612345678",
      slotid: 1,
      insert_time: ts,
      card_holder_name: "Doctor Who's Universe",
      expiration_date: 1.year.after(Date.current)

    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/CT_ID_0176/)
    expect(rendered).to match(/GemaCard/)
    expect(rendered).to match(/some other text/)
    expect(rendered).to match(/7fb65ede-0a37-11ef-8f85-c025a5b36994/)
    expect(rendered).to match(/SMB-C/)
    expect(rendered).to match(/8027612345678/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/#{ts.to_s}/)
    expect(rendered).to match(/Doctor Who&#39;s Universe/)
    expect(rendered).to match(/#{1.year.after(Date.current)}/)
  end
end
