require "rails_helper"

module Cards
  RSpec.describe LogsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/cards/88/logs").to route_to(controller: "cards/logs", action: "index", card_id: '88')
      end
    end
  end
end
