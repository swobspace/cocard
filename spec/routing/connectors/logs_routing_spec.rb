require "rails_helper"

module Connectors
  RSpec.describe LogsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/connectors/88/logs").to route_to(controller: "connectors/logs", action: "index", connector_id: '88')
      end
    end
  end
end
