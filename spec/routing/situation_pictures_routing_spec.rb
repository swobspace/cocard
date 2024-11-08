require "rails_helper"

RSpec.describe SituationPictureController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/situation_picture").to route_to("situation_picture#index")
    end

    it "routes to #failed" do
      expect(get: "/situation_picture/failed").to route_to("situation_picture#failed")
    end

  end
end
