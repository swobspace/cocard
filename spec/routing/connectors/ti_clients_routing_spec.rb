require "rails_helper"

RSpec.describe Connectors::TIClientsController, type: :routing do
  describe "routing" do

    it "routes to #new" do
      expect(get: "/connectors/88/ti_client/new").to route_to("connectors/ti_clients#new", connector_id: '88')
    end

    it "routes to #show" do
      expect(get: "/connectors/88/ti_client").to route_to("connectors/ti_clients#show", connector_id: '88')
    end

    it "routes to #edit" do
      expect(get: "/connectors/88/ti_client/edit").to route_to("connectors/ti_clients#edit", connector_id: '88')
    end


    it "routes to #create" do
      expect(post: "/connectors/88/ti_client").to route_to("connectors/ti_clients#create", connector_id: '88')
    end

    it "routes to #update via PUT" do
      expect(put: "/connectors/88/ti_client").to route_to("connectors/ti_clients#update",  connector_id: '88')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/connectors/88/ti_client").to route_to("connectors/ti_clients#update", connector_id: '88')
    end

    it "routes to #destroy" do
      expect(delete: "/connectors/88/ti_client").to route_to("connectors/ti_clients#destroy", connector_id: '88')
    end
  end
end
