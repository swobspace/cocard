require "rails_helper"

module CardTerminals
  RSpec.describe LogsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/card_terminals/88/logs").to route_to(controller: "card_terminals/logs", action: "index", card_terminal_id: '88')
      end
    end
  end
end
