require 'rails_helper'

RSpec.describe "contexts/index", type: :view do
  before(:each) do
    assign(:contexts, [
      Context.create!(
        mandant: "Mandant",
        client_system: "Client System",
        workplace: "Workplace",
        description: "Description"
      ),
      Context.create!(
        mandant: "Mandant",
        client_system: "Client System",
        workplace: "Workplace",
        description: "Description"
      )
    ])
  end

  it "renders a list of contexts" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Mandant".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Client System".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Workplace".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end
