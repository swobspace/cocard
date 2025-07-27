require 'rails_helper'

RSpec.describe "Card", type: :feature, js: true do
  let(:ts)        { Time.current }
  let(:location)  { FactoryBot.create(:location, lid: 'AXC') }
  let(:in_betrieb) { FactoryBot.create(:operational_state, :in_betrieb) }


  let!(:card) do
    FactoryBot.create(:card,
      name: "Some Organisation",
      description: "some other description",
      private_information: "some other private information",
      location_id: location.id,
      operational_state: in_betrieb,
      lanr: "lanr1234",
      bsnr: "bsnr1234",
      fachrichtung: "fachrichtung1234",
      telematikid: "telematikid1234",
      iccsn: "iccsn1234",
      card_type: 'SMC-B',
      card_holder_name: "Some Card Holder",
    )
  end

  before(:each) do
    login_user(role: 'Admin')
    visit card_path(card)
  end

  it "visit card_path" do
    expect(page).to have_content("Karte: ##{card.id}")
    expect(page).to have_content("SMC-B: iccsn1234 - Some Card Holder".to_s)
  end

  it "delete an existing terminal" do
    expect(page).to have_content("SMC-B: iccsn1234 - Some Card Holder".to_s)
    expect(Card.count).to eq(1)
    accept_confirm do
      find('a[title="Karte löschen"]').click
    end
    within "#cards_table_wrapper" do
      expect(page).to have_content "0 bis 0 von 0 Einträgen"
    end
    expect(Card.count).to eq(0)
  end

  it "copy card" do
    find('a[title="Karte kopieren"]').click
    expect(page).to have_content("Karte kopieren")
    expect(page).not_to have_content("iccsn1234")
    # expect(page).not_to have_content("in Betrieb")
    within "form#new_card" do
      fill_in "ICCSN", with: "ICCSN0123456789"
      click_button("Karte erstellen")
    end
    expect(page).to have_content("Karte: #")
    expect(page).to have_content("SMC-B: ICCSN0123456789 - Some Card Holder".to_s)
    expect(page).to have_content("lanr1234")
    expect(page).to have_content("some other description")
    find('i[data-show-secret-target="icon"]').click
    # save_and_open_screenshot()
    expect(page).to have_content("some other private information")
  end

  it "edit card" do
    find('a[title="Karte bearbeiten"]').click
    within "form#edit_card_#{card.id}" do
      fill_in "LANR", with: "lanr5678"
      click_button("Karte aktualisieren")
    end
    # save_and_open_screenshot()
    expect(page).to have_content("Karte: ##{card.id}")
    expect(page).to have_content("SMC-B: iccsn1234 - Some Card Holder".to_s)
    expect(page).to have_content("lanr5678")
  end

  it "add new card" do
    visit new_card_path
    within "form#new_card" do
      fill_in "LANR", with: "LANR9898987"
      fill_in "ICCSN", with: "iccsn0123456789"
      click_button("Karte erstellen")
    end
    expect(page).to have_content("Karte erfolgreich erstellt")
    expect(page).to have_content("Karte: #")
    expect(page).to have_content("LANR9898987")
    expect(page).to have_content("iccsn0123456789")
    # save_and_open_screenshot()
  end
end
