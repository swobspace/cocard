require 'rails_helper'

RSpec.describe "/operational_states", type: :request do
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:operational_state)
  }

  let(:invalid_attributes) {{
    name: nil
  }}

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      OperationalState.create! valid_attributes
      get operational_states_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      operational_state = OperationalState.create! valid_attributes
      get operational_state_url(operational_state)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_operational_state_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      operational_state = OperationalState.create! valid_attributes
      get edit_operational_state_url(operational_state)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new OperationalState" do
        expect {
          post operational_states_url, params: { operational_state: valid_attributes }
        }.to change(OperationalState, :count).by(1)
      end

      it "redirects to the created operational_state" do
        post operational_states_url, params: { operational_state: valid_attributes }
        expect(response).to redirect_to(operational_state_url(OperationalState.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new OperationalState" do
        expect {
          post operational_states_url, params: { operational_state: invalid_attributes }
        }.to change(OperationalState, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post operational_states_url, params: { operational_state: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        name: "roquefort",
        description: "dont knoff",
        operational: true
      }}

      it "updates the requested operational_state" do
        operational_state = OperationalState.create! valid_attributes
        patch operational_state_url(operational_state), params: { operational_state: new_attributes }
        operational_state.reload
        expect(operational_state.name).to eq('roquefort')
        expect(operational_state.description).to eq('dont knoff')
        expect(operational_state.operational).to be_truthy
      end

      it "redirects to the operational_state" do
        operational_state = OperationalState.create! valid_attributes
        patch operational_state_url(operational_state), params: { operational_state: new_attributes }
        operational_state.reload
        expect(response).to redirect_to(operational_state_url(operational_state))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        operational_state = OperationalState.create! valid_attributes
        patch operational_state_url(operational_state), params: { operational_state: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested operational_state" do
      operational_state = OperationalState.create! valid_attributes
      expect {
        delete operational_state_url(operational_state)
      }.to change(OperationalState, :count).by(-1)
    end

    it "redirects to the operational_states list" do
      operational_state = OperationalState.create! valid_attributes
      delete operational_state_url(operational_state)
      expect(response).to redirect_to(operational_states_url)
    end
  end
end
