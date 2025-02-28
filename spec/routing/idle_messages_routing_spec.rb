require "rails_helper"

RSpec.describe CardsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/idle_messages").to route_to("idle_messages#index")
    end

    it "routes to #edit" do
      expect(get: "/idle_messages/edit").to route_to("idle_messages#edit")
    end

    it "routes to #update via PUT" do
      expect(put: "/idle_messages").to route_to("idle_messages#update")
    end

  end
end
