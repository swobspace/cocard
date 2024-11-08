require 'rails_helper'

RSpec.describe "SituationPictures", type: :request do
  before(:each) do
    login_admin
  end

  describe "GET /situation_picture" do
    it "returns http success" do
      get "/situation_picture"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /situation_picture/failed" do
    it "returns http success" do
      get "/situation_picture/failed"
      expect(response).to have_http_status(:success)
    end
  end

end
