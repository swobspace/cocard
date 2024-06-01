require 'rails_helper'
RSpec.describe "/networks", type: :request do
  let(:location) { FactoryBot.create(:location) }
  
  let(:valid_attributes) {
    { location_id: location.id, netzwerk: '198.51.100.64/27' }
  }

  let(:invalid_attributes) {
    { location_id: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      Network.create! valid_attributes
      get networks_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      network = Network.create! valid_attributes
      get network_url(network)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_network_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      network = Network.create! valid_attributes
      get edit_network_url(network)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Network" do
        expect {
          post networks_url, params: { network: valid_attributes }
        }.to change(Network, :count).by(1)
      end

      it "redirects to the created network" do
        post networks_url, params: { network: valid_attributes }
        expect(response).to redirect_to(network_url(Network.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Network" do
        expect {
          post networks_url, params: { network: invalid_attributes }
        }.to change(Network, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post networks_url, params: { network: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { description: 'some more information' }
      }

      it "updates the requested network" do
        network = Network.create! valid_attributes
        patch network_url(network), params: { network: new_attributes }
        network.reload
        expect(network.description.to_plain_text).to eq("some more information")
      end

      it "redirects to the network" do
        network = Network.create! valid_attributes
        patch network_url(network), params: { network: new_attributes }
        network.reload
        expect(response).to redirect_to(network_url(network))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        network = Network.create! valid_attributes
        patch network_url(network), params: { network: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested network" do
      network = Network.create! valid_attributes
      expect {
        delete network_url(network)
      }.to change(Network, :count).by(-1)
    end

    it "redirects to the networks list" do
      network = Network.create! valid_attributes
      delete network_url(network)
      expect(response).to redirect_to(networks_url)
    end
  end
end
