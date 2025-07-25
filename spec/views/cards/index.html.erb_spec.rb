require 'rails_helper'

RSpec.describe "cards/index", type: :view do
  let(:location) { FactoryBot.create(:location, lid: 'AXXC') }
  let(:conn) { FactoryBot.create(:connector, name: 'TIK-XXX-39') }
  let!(:ct) do
    FactoryBot.create(:card_terminal, :with_mac, 
      connector: conn, 
      ct_id: 'CT_ID_0176',
      location: location
    ) 
  end
  let(:ops) { FactoryBot.create(:operational_state, name: 'im Schrank') }

  let(:ts) { Time.current }
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(controller).to receive(:current_ability) { @ability }
    allow(controller).to receive(:controller_name) { 'cards' }
    allow(controller).to receive(:action_name) { 'index' }
    @cards = [
      card1 = Card.create!(
        name: "GemaCard",
        description: "some other text",
        card_handle: "7fb65ede-0a37-11ef-8f85-c025a5b36994",
        card_type: "SMC-B",
        iccsn: "8027612345678",
        insert_time: ts,
        card_holder_name: "Doctor Who's Universe",
        expiration_date: 1.year.after(Date.current),
        operational_state_id: ops.id,
        location_id: location.id,
        last_ok: 1.month.before(ts),
        insert_time: 1.week.before(ts),
        last_check: ts,
        lanr: "999777333",
        bsnr: "222444667",
        telematikid: "1-2-3-456",
        fachrichtung: "Innere Medizin",
        object_system_version: "4.7.11",
        cert_subject_cn: "Card Gema",
        cert_subject_title: "Dr. med.",
        cert_subject_sn: "Mustermann",
        cert_subject_givenname: "Gottfried",
        cert_subject_street: "Holzweg 14",
        cert_subject_postalcode: "99979",
        cert_subject_l: "Nirgendwo",
        cert_subject_o: "22244466688",
        private_information: "StrengGeheim"
      ),
      card2 = Card.create!(
        name: "GemaCard",
        description: "some other text",
        card_handle: "7fb65ede-0a37-11ef-8f85-c025a5b36994",
        card_type: "SMC-KT",
        iccsn: "8027612345699",
        # slotid: 222999,
        expiration_date: 1.year.after(Date.current),
        operational_state_id: ops.id,
        location_id: location.id,
        last_ok: 1.month.before(ts),
        insert_time: 1.week.before(ts),
        last_check: ts,
        lanr: "999777333",
        bsnr: "222444667",
        telematikid: "1-2-3-456",
        object_system_version: "4.7.11",
        fachrichtung: "Innere Medizin",
        cert_subject_cn: "Card Gema",
        cert_subject_title: "Dr. med.",
        cert_subject_sn: "Mustermann",
        cert_subject_givenname: "Gottfried",
        cert_subject_street: "Holzweg 14",
        cert_subject_postalcode: "99979",
        cert_subject_l: "Nirgendwo",
        cert_subject_o: "22244466688",
        private_information: "StrengGeheim"
      )
    ]
    card1.create_card_terminal_slot(card_terminal_id: ct.id, slotid: 22888)
    card1.reload
  end

  it "renders a list of cards" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("TIK-XXX-39"), count: 1
    assert_select cell_selector, text: Regexp.new(ct.ct_id), count: 1
    assert_select cell_selector, text: Regexp.new("GemaCard".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Card Gema".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("7fb65ede-0a37-11ef-8f85-c025a5b36994".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("SMC-KT".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("SMC-B".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("8027612345678".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("8027612345699".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("22888".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("22999".to_s), count: 0
    assert_select cell_selector, text: Regexp.new("4.7.11".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(1.month.before(ts).localtime.to_s.gsub(/\+.*/,'')), count: 2
    assert_select cell_selector, text: Regexp.new(1.week.before(ts).localtime.to_s.gsub(/\+.*/,'')), count: 2
    assert_select cell_selector, text: Regexp.new(ts.localtime.to_s.gsub(/\+.*/,'')), count: 2
    assert_select cell_selector, text: Regexp.new(1.year.after(Date.current).to_s), count: 2
    assert_select cell_selector, text: Regexp.new("im Schrank".to_s), count: 4
    assert_select cell_selector, text: Regexp.new("AXXC".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("999777333".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("222444667".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("1-2-3-456".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Innere Medizin".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Dr. med.".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Mustermann".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Gottfried".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Holzweg 14".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("99979".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Nirgendwo".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("22244466688".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("StrengGeheim".to_s), count: 0
    assert_select cell_selector, text: Regexp.new("Karte nicht in Betrieb".to_s), count: 0
  end
end
