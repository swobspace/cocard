require 'rails_helper'

RSpec.describe "/connectors", type: :request do
  let(:location) { FactoryBot.create(:location) }
  let(:clientcert) { FactoryBot.create(:client_certificate) }
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:connector)
  }

  let(:invalid_attributes) {
    { ip: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      Connector.create! valid_attributes
      get connectors_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      connector = Connector.create! valid_attributes
      get connector_url(connector)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_connector_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      connector = Connector.create! valid_attributes
      get edit_connector_url(connector)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Connector" do
        expect {
          post connectors_url, params: { connector: valid_attributes }
        }.to change(Connector, :count).by(1)
      end

      it "redirects to the created connector" do
        post connectors_url, params: { connector: valid_attributes }
        expect(response).to redirect_to(connector_url(Connector.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Connector" do
        expect {
          post connectors_url, params: { connector: invalid_attributes }
        }.to change(Connector, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post connectors_url, params: { connector: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        description: "HighSpeed",
        admin_url: 'http://1.2.3.4:5678',
        sds_url: 'http://192.0.2.99',
        manual_update: true,
        location_ids: [location.id],
        client_certificate_ids: [clientcert.id],
        id_contract: '919ZKK43',
        serial: 'S12344321',
        use_tls: true,
        authentication: :clientcert,
        auth_user: "intern",
        auth_password: "secret"
      }}

      it "updates the requested connector" do
        connector = Connector.create! valid_attributes
        patch connector_url(connector), params: { connector: new_attributes }
        connector.reload
        expect(connector.description.to_plain_text).to eq('HighSpeed')
        expect(connector.admin_url).to eq('http://1.2.3.4:5678')
        expect(connector.sds_url).to eq('http://192.0.2.99')
        expect(connector.locations).to contain_exactly(location)
        expect(connector.client_certificates).to contain_exactly(clientcert)
        expect(connector.serial).to eq('S12344321')
        expect(connector.id_contract).to eq('919ZKK43')
        expect(connector.use_tls).to eq(true)
        expect(connector.authentication).to eq('clientcert')
        expect(connector.auth_user).to eq('intern')
        expect(connector.auth_password).to eq('secret')
      end

      it "redirects to the connector" do
        connector = Connector.create! valid_attributes
        patch connector_url(connector), params: { connector: new_attributes }
        connector.reload
        expect(response).to redirect_to(connector_url(connector))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        connector = Connector.create! valid_attributes
        patch connector_url(connector), params: { connector: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested connector" do
      connector = Connector.create! valid_attributes
      expect {
        delete connector_url(connector)
      }.to change(Connector, :count).by(-1)
    end

    it "redirects to the connectors list" do
      connector = Connector.create! valid_attributes
      delete connector_url(connector)
      expect(response).to redirect_to(connectors_url)
    end
  end
end
