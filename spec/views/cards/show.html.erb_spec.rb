require 'rails_helper'

RSpec.describe "cards/show", type: :view do
  let(:ct) { FactoryBot.create(:card_terminal, ct_id: 'CT_ID_0176') }
  let(:ops) { FactoryBot.create(:operational_state, name: 'im Schrank') }
  let(:location) { FactoryBot.create(:location, lid: 'AXXC') }
  let(:context) do
     FactoryBot.create(:context,
       mandant: "CDEFAB",
       client_system: "MySoft",
       workplace: "Evergreen"
     )
  end
  let(:ts) { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'cards' }
    allow(controller).to receive(:action_name) { 'show' }
    assign(:card, Card.create!(
      card_terminal_id: ct.id,
      context_id: context.id,
      name: "GemaCard",
      description: "some other text",
      card_handle: "7fb65ede-0a37-11ef-8f85-c025a5b36994",
      card_type: "SMB-C",
      iccsn: "8027612345678",
      insert_time: ts,
      card_holder_name: "Doctor Who's Universe",
      expiration_date: 1.year.after(Date.current),
      slotid: 22232,
      operational_state_id: ops.id,
      location_id: location.id,
      lanr: "999777333",
      bsnr: "222444666",
      telematikid: "1-2-3-456",
      fachrichtung: "Innere Medizin",
      cert_subject_cn: "Card Gema",
      cert_subject_title: "Dr. med.",
      cert_subject_sn: "Mustermann",
      cert_subject_givenname: "Gottfried",
      cert_subject_street: "Holzweg 14",
      cert_subject_postalcode: "99979",
      cert_subject_l: "Nirgendwo",
      cert_subject_o: "987654"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/CT_ID_0176/)
    expect(rendered).to match(/GemaCard/)
    expect(rendered).to match(/Card Gema/)
    expect(rendered).to match(/some other text/)
    expect(rendered).to match(/7fb65ede-0a37-11ef-8f85-c025a5b36994/)
    expect(rendered).to match(/SMB-C/)
    expect(rendered).to match(/8027612345678/)
    expect(rendered).to match(/22232/)
    expect(rendered).to match(/#{ts.to_s}/)
    expect(rendered).to match(/Doctor Who&#39;s Universe/)
    expect(rendered).to match(/#{1.year.after(Date.current)}/)
    expect(rendered).to match(/999777333/)
    expect(rendered).to match(/222444666/)
    expect(rendered).to match(/AXXC/)
    expect(rendered).to match(/im Schrank/)
    expect(rendered).to match(/1-2-3-456/)
    expect(rendered).to match(/Innere Medizin/)
    expect(rendered).to match(/Dr. med./)
    expect(rendered).to match(/Mustermann/)
    expect(rendered).to match(/Gottfried/)
    expect(rendered).to match(/Holzweg 14/)
    expect(rendered).to match(/99979/)
    expect(rendered).to match(/Nirgendwo/)
    expect(rendered).to match(/987654/)
    expect(rendered).to match(/CDEFAB - MySoft - Evergreen/)
  end
end
