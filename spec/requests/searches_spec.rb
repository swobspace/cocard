require 'rails_helper'

RSpec.describe "Searches", type: :request do
  before(:each) do
    login_admin
  end

  describe "GET /search with search params" do
    it "returns http success" do
      get search_url(query: 'tag:MyTag K03')
      expect(response).to have_http_status(:success)
    end
  end

end
