require "rails_helper"

module Cards
  RSpec.describe LogsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/cards/88/logs").to route_to(controller: "cards/logs", action: "index", card_id: '88')
      end
      it "routes to #show" do
        expect(get: "/cards/88/logs/1").to route_to(controller: "cards/logs", action: "show", card_id: '88', id: '1')
      end
      it "routes to #destroy" do
        expect(delete: "/cards/88/logs/1").to route_to(controller: "cards/logs", action: "destroy", card_id: '88', id: '1')
      end
    end
  end
end
