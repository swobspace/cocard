require 'rails_helper'

RSpec.describe "VZDs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      skip "mocking ldap query not yet implemented"
      get "/vzd/index?telematikid=12345678"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search" do
    it "returns http success" do
      get "/vzd/search"
      expect(response).to have_http_status(:success)
    end
  end

end
