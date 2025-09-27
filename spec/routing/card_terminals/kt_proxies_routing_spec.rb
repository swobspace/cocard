require "rails_helper"

RSpec.describe CardTerminals::KTProxiesController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/card_terminals/88/kt_proxy/new").to route_to("card_terminals/kt_proxies#new", card_terminal_id: '88')
    end
  end
end
