require "rails_helper"

module Locations
  RSpec.describe ConnectorsController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/locations/87/connectors").to route_to(controller: "locations/connectors", action: "index", location_id: '87')
      end

      it "routes to #new" do
        skip "spec for #new not routable doesn't work"
        expect(get: "/locations/87/connectors/new").not_to be_routable
      end

      it "routes to #show" do
        expect(get: "/locations/87/connectors/1").to route_to(controller: "locations/connectors", action: "show", id: "1", location_id: '87')
      end

      it "routes to #edit" do
        expect(get: "/locations/87/connectors/1/edit").not_to be_routable
      end

      it "routes to #create" do
        expect(post: "/locations/87/connectors").not_to be_routable
      end

      it "routes to #update via PUT" do
        expect(put: "/locations/87/connectors/1").not_to be_routable
      end

      it "routes to #update via PATCH" do
        expect(patch: "/locations/87/connectors/1").not_to be_routable
      end

      it "routes to #destroy" do
        expect(delete: "/locations/87/connectors/1").to route_to(controller: "locations/connectors", action: "destroy", id: "1", location_id: '87')
      end
    end
  end
end
