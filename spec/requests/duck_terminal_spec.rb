require 'rails_helper'

RSpec.describe "DuckTerminals", type: :request do
  before(:each) do
    login_admin
  end

  describe "GET /new" do
    it "returns http success" do
      get "/duck_terminal/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "with rmi port unreachable" do
    let(:new_params) {{
      duck_terminal: {
        ip: '127.0.0.4',
        identification: 'INGHC-ORGA6100',
        firmware_version: '3.9.0'
      }
    }}

    describe "GET #show" do
      it "returns http success" do
        get duck_terminal_url, params: new_params
        expect(response).to have_http_status(:success)
        # puts response.body
        expect(response.body).to match('Abfrage des Kartenterminals fehlgeschlagen')
        expect(response.body).to match('RMI-Port 443 unreachable!')
      end
    end
  end

  describe "with unsupported firmware version" do
    let(:new_params) {{
      duck_terminal: {
        ip: '127.0.0.4',
        identification: 'INGHC-ORGA6100',
        firmware_version: '1.1.1'
      }
    }}

    describe "GET #show" do
      it "returns http success" do
        get duck_terminal_url, params: new_params
        expect(response).to have_http_status(:success)
        # puts response.body
        expect(response.body).to match('Kartenterminal wird nicht unterstützt')
        expect(response.body).to match('unsupported')
      end
    end
  end

  describe "with supported terminal", rmi: true do
    let(:new_params) {{
      duck_terminal: {
        ip: ENV['CT_IP'],
        identification: 'INGHC-ORGA6100',
        firmware_version: '3.9.0'
      }
    }}

    describe "GET #show" do
      it "returns http success" do
        get duck_terminal_url, params: new_params
        expect(response).to have_http_status(:success)
        puts response.body
        expect(response.body).to match('000DF80C8652')
        expect(response.body).to match('ORGA6100-0241000000B692')
      end
    end
  end

end
