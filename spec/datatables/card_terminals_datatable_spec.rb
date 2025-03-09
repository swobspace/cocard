require 'rails_helper'

module CardTerminalsDatatableHelper
  include ApplicationHelper
  def card_terminal2array(ct)
    [].tap do |column|
      column <<  "RENDER"
      column <<  ct.condition_message
      column <<  ct.displayname
      column <<  ct.ct_id
      column <<  ct.connector&.name
      column <<  ct.name
      column <<  ct.mac.to_s
      column <<  ct.ip.to_s
      column <<  ct.connected.to_s
      column <<  ct.location&.lid
      column <<  ct.room
      column <<  ct.plugged_in
      column <<  ct.contact
      column <<  ct.idle_message
      column <<  ct.delivery_date.to_s
      column <<  ct.supplier
      column <<  ct.serial
      column <<  ct.id_product
      column <<  ct.firmware_version
      column <<  ct.description.to_plain_text
      column << I18n.t(ct.pin_mode, scope: 'pin_modes').to_s
      column <<  ct.smckt&.iccsn.to_s
      column << "RENDER"
      column << "RENDER"
      column << "RENDER"

      column << "  " # dummy for action links
    end
  end

  def link_helper(text, url)
    text
  end 
end

RSpec.describe CardTerminalsDatatable, type: :model do
  include CardTerminalsDatatableHelper
  include_context "card_terminal variables"

  let(:view_context) { double("ActionView::Base") }
  let(:card_terminals) do
    CardTerminal.left_outer_joins(:location, :connector, card_terminal_slots: :card)
  end
  let(:datatable)    { CardTerminalsDatatable.new(card_terminals, view_context) }
  let(:myparams)  {{}}

  before(:each) do
    allow(view_context).to receive(:params).and_return(myparams)
    allow(view_context).to receive_messages(
      edit_card_terminal_path: "",
      card_terminal_path: "",
      connector_path: "",
      show_link: "",
      edit_link: "",
      delete_link: "",
      render: "RENDER"
    )
    allow(view_context).to receive(:link_to) do |text, url|
      link_helper(text, url)
    end
  end

  describe "without search params, start:0, length:10" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"0"=> {search: {value: ""}}},
      order: {"0"=>{column: "2", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(3) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct1)) }
    it { expect(parse_json(subject, "data/2")).to eq(card_terminal2array(ct3)) }
  end 

  describe "without search params, start:2, length:2" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"0"=> {search: {value: ""}}},
      order: {"0"=>{column: "2", dir: "asc"}},
      start: "2",
      length: "2",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(3) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct3)) }
  end 

  describe "column 0: condition, search: OK" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"0"=> {search: {value: "NOTHING", regex: "false"}}},
      order: {"0"=>{column: "2", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(2) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct1)) }
    it { expect(parse_json(subject, "data/1")).to eq(card_terminal2array(ct3)) }
  end 

  describe "column 1: condition_message " do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"1"=> {search: {value: "Kein Konnektor zugewiesen", regex: "false"}}},
      order: {"0"=>{column: "2", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(2) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct1)) }
    it { expect(parse_json(subject, "data/1")).to eq(card_terminal2array(ct3)) }
  end 

  describe "column 2: display name " do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"2"=> {search: {value: "ct2", regex: "false"}}},
      order: {"0"=>{column: "1", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(1) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct2)) }
  end 

  describe "column 3: ct_id" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"3"=> {search: {value: "CT_ID_000", regex: "false"}}},
      order: {"0"=>{column: "3", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(2) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct1)) }
    it { expect(parse_json(subject, "data/1")).to eq(card_terminal2array(ct3)) }
  end 

  describe "column 4: connector.name" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"4"=> {search: {value: "127", regex: "false"}}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(1) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct2)) }
  end 

  describe "column 5: connector.name" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"5"=> {search: {value: "CWZ", regex: "false"}}},
      order: {"0"=>{column: "5", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(2) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct2)) }
    it { expect(parse_json(subject, "data/1")).to eq(card_terminal2array(ct3)) }
  end 

  describe "column 6: mac" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"6"=> {search: {value: "445566", regex: "false"}}},
      order: {"0"=>{column: "6", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(1) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct2)) }
  end 

  describe "column 7: ip" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"7"=> {search: {value: "127.5", regex: "false"}}},
      order: {"0"=>{column: "7", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(2) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct3)) }
    it { expect(parse_json(subject, "data/1")).to eq(card_terminal2array(ct1)) }
  end 

  describe "column 8: connected" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"8"=> {search: {value: "ja", regex: "false"}}},
      order: {"0"=>{column: "8", dir: "asc"}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(1) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct1)) }
  end 


  describe "column 9: lid" do
    let(:myparams) { ActiveSupport::HashWithIndifferentAccess.new(
      columns: {"9"=> {search: {value: "BER", regex: "false"}}},
      start: "0",
      length: "10",
      search: {value: "", regex: "false"}
    )}
    subject { datatable.to_json }
    it { expect(datatable).to be_a_kind_of CardTerminalsDatatable }
    it { expect(parse_json(subject, "recordsTotal")).to eq(3) }
    it { expect(parse_json(subject, "recordsFiltered")).to eq(1) }
    it { expect(parse_json(subject, "data/0")).to eq(card_terminal2array(ct1)) }
  end 

end
