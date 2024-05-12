require "rails_helper"

RSpec.describe OperationalStatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/operational_states").to route_to("operational_states#index")
    end

    it "routes to #new" do
      expect(get: "/operational_states/new").to route_to("operational_states#new")
    end

    it "routes to #show" do
      expect(get: "/operational_states/1").to route_to("operational_states#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/operational_states/1/edit").to route_to("operational_states#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/operational_states").to route_to("operational_states#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/operational_states/1").to route_to("operational_states#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/operational_states/1").to route_to("operational_states#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/operational_states/1").to route_to("operational_states#destroy", id: "1")
    end
  end
end
