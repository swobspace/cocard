require "rails_helper"

module Connectors
  RSpec.describe CardTerminalsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/connectors/87/card_terminals").to route_to(controller: "connectors/card_terminals", action: "index", connector_id: '87')
      end

      it "routes to #new" do
        skip "spec for #new not routable doesn't work"
        expect(get: "/connectors/87/card_terminals/new").not_to be_routable
      end

      it "routes to #show" do
        expect(get: "/connectors/87/card_terminals/1").to route_to(controller: "connectors/card_terminals", action: "show", id: "1", connector_id: '87')
      end

      it "routes to #edit" do
        expect(get: "/connectors/87/card_terminals/1/edit").not_to be_routable
      end

      it "routes to #create" do
        expect(post: "/connectors/87/card_terminals").not_to be_routable
      end

      it "routes to #update via PUT" do
        expect(put: "/connectors/87/card_terminals/1").not_to be_routable
      end

      it "routes to #update via PATCH" do
        expect(patch: "/connectors/87/card_terminals/1").not_to be_routable
      end

      it "routes to #destroy" do
        expect(delete: "/connectors/87/card_terminals/1").to route_to(controller: "connectors/card_terminals", action: "destroy", id: "1", connector_id: '87')
      end
    end
  end
end
