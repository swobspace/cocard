require "rails_helper"

module Connectors
  RSpec.describe LogsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/connectors/88/logs").to route_to(controller: "connectors/logs", action: "index", connector_id: '88')
      end
      it "routes to #show" do
        expect(get: "/connectors/88/logs/1").to route_to(controller: "connectors/logs", action: "show", connector_id: '88', id: '1')
      end
      it "routes to #destroy" do
        expect(delete: "/connectors/88/logs/1").to route_to(controller: "connectors/logs", action: "destroy", connector_id: '88', id: '1')
      end
    end
  end
end
