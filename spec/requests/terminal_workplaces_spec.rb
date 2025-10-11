require 'rails_helper'

RSpec.describe "TerminalWorkplaces", type: :request do

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "returns http success" do
      get terminal_workplaces_path
      expect(response).to have_http_status(:success)
    end
  end

end
