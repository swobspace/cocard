require 'rails_helper'

RSpec.describe "cards/index", type: :view do
  let(:conn) { FactoryBot.create(:connector, name: 'TIK-XXX-39') }
  let(:ct) { FactoryBot.create(:card_terminal, connector: conn, ct_id: 'CT_ID_0176') }
  let(:ops) { FactoryBot.create(:operational_state, name: 'im Schrank') }
  let(:location) { FactoryBot.create(:location, lid: 'AXXC') }

  let(:ts) { Time.current }
  before(:each) do
    assign(:cards, [
      Card.create!(
        card_terminal_id: ct.id,
        name: "GemaCard",
        description: "some other text",
        card_handle: "7fb65ede-0a37-11ef-8f85-c025a5b36994",
        card_type: "SMC-B",
        iccsn: "8027612345678",
        slotid: 22888,
        insert_time: ts,
        card_holder_name: "Doctor Who's Universe",
        expiration_date: 1.year.after(Date.current),
        operational_state_id: ops.id,
        location_id: location.id,
        lanr: "999777333",
        bsnr: "222444666",
        telematikid: "1-2-3-456",
        fachrichtung: "Innere Medizin",
        cert_subject_title: "Dr. med.",
        cert_subject_sn: "Mustermann",
        cert_subject_givenname: "Gottfried",
        cert_subject_street: "Holzweg 14",
        cert_subject_postalcode: "99979",
        cert_subject_l: "Nirgendwo"
      ),
      Card.create!(
        name: "GemaCard",
        description: "some other text",
        card_handle: "7fb65ede-0a37-11ef-8f85-c025a5b36994",
        card_type: "SMC-KT",
        iccsn: "8027612345699",
        slotid: 222999,
        insert_time: ts,
        expiration_date: 1.year.after(Date.current),
        operational_state_id: ops.id,
        location_id: location.id,
        lanr: "999777333",
        bsnr: "222444666",
        telematikid: "1-2-3-456",
        fachrichtung: "Innere Medizin",
        cert_subject_title: "Dr. med.",
        cert_subject_sn: "Mustermann",
        cert_subject_givenname: "Gottfried",
        cert_subject_street: "Holzweg 14",
        cert_subject_postalcode: "99979",
        cert_subject_l: "Nirgendwo"
      )
    ])
  end

  it "renders a list of cards" do
    render
    cell_selector = 'tr>td'
    assert_select cell_selector, text: Regexp.new("TIK-XXX-39"), count: 1
    assert_select cell_selector, text: Regexp.new(ct.ct_id), count: 1
    assert_select cell_selector, text: Regexp.new("GemaCard".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("7fb65ede-0a37-11ef-8f85-c025a5b36994".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("SMC-KT".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("SMC-B".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("8027612345678".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("8027612345699".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("22888".to_s), count: 1
    assert_select cell_selector, text: Regexp.new("22999".to_s), count: 1
    assert_select cell_selector, text: Regexp.new(ts.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(1.year.after(Date.current).to_s), count: 2
    assert_select cell_selector, text: Regexp.new("im Schrank".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("AXXC".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("999777333".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("222444666".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("1-2-3-456".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Innere Medizin".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Dr. med.".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Mustermann".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Gottfried".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Holzweg 14".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("99979".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Nirgendwo".to_s), count: 2
  end
end
