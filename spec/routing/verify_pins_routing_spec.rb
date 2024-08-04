require "rails_helper"

RSpec.describe VerifyPinsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/verify_pins").to route_to("verify_pins#index")
    end

    it "routes to #verify" do
      expect(post: "/verify_pins?card_terminal_id=1").to route_to("verify_pins#verify", card_terminal_id: "1")
    end

  end
end
