require "rails_helper"

RSpec.describe TIClients::KTProxiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ti_clients/88/kt_proxies").to route_to("ti_clients/kt_proxies#index", ti_client_id: '88')
    end
  end
end
