require 'rails_helper'

RSpec.describe "DuckTerminals", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/duck_terminal/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/duck_terminal/create"
      expect(response).to have_http_status(:success)
    end
  end

end
