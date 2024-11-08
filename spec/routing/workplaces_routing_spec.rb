require "rails_helper"

RSpec.describe WorkplacesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/workplaces").to route_to("workplaces#index")
    end

    it "routes to #new" do
      expect(get: "/workplaces/new").to route_to("workplaces#new")
      # skip "test won't work"
      # expect(get: "/workplaces/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/workplaces/1").to route_to("workplaces#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/workplaces/1/edit").to route_to("workplaces#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/workplaces").to route_to("workplaces#create")
      # expect(post: "/workplaces").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(put: "/workplaces/1").to route_to("workplaces#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/workplaces/1").to route_to("workplaces#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/workplaces/1").to route_to("workplaces#destroy", id: "1")
    end

    it "routes to #delete_outdated" do
      expect(delete: "/workplaces/delete_outdated").to route_to("workplaces#delete_outdated")
    end

    it "routes to #new_import" do
      expect(:get => "/workplaces/new_import").to route_to("workplaces#new_import")
    end

    it "routes to #import" do
      expect(:post => "/workplaces/import").to route_to("workplaces#import")
    end
  end
end
