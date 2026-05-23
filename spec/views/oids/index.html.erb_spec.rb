require 'rails_helper'

RSpec.describe "oids/index", type: :view do
  before(:each) do
    assign(:oids, [
      Oid.create!(
        oid: "Oid",
        name: "Name",
        reference: "Reference"
      ),
      Oid.create!(
        oid: "Oid",
        name: "Name",
        reference: "Reference"
      )
    ])
  end

  it "renders a list of oids" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Oid".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Reference".to_s), count: 2
  end
end
