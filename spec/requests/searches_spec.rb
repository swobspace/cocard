require 'rails_helper'

RSpec.describe "Searches", type: :request do
  before(:each) do
    login_admin
  end

  describe "GET /search" do
    it "returns http success" do
      get "/search"
      expect(response).to have_http_status(:success)
    end
  end

end
