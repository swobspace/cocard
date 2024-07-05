require "rails_helper"

module CardTerminals
  RSpec.describe LogsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/card_terminals/88/logs").to route_to(controller: "card_terminals/logs", action: "index", card_terminal_id: '88')
      end
      it "routes to #show" do
        expect(get: "/card_terminals/88/logs/1").to route_to(controller: "card_terminals/logs", action: "show", card_terminal_id: '88', id: '1')
      end
      it "routes to #destroy" do
        expect(delete: "/card_terminals/88/logs/1").to route_to(controller: "card_terminals/logs", action: "destroy", card_terminal_id: '88', id: '1')
      end
    end
  end
end
