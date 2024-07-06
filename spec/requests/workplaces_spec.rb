require 'rails_helper'

RSpec.describe "/workplaces", type: :request do
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:workplace)
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      Workplace.create! valid_attributes
      get workplaces_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      workplace = Workplace.create! valid_attributes
      get workplace_url(workplace)
      expect(response).to be_successful
    end
  end

   describe "GET /new" do
     it "renders a successful response" do
       get new_workplace_url
       expect(response).to be_successful
     end
   end

  describe "GET /edit" do
    it "renders a successful response" do
      workplace = Workplace.create! valid_attributes
      get edit_workplace_url(workplace)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Workplace" do
        expect {
          post workplaces_url, params: { workplace: valid_attributes }
        }.to change(Workplace, :count).by(1)
      end

      it "redirects to the created workplace" do
        post workplaces_url, params: { workplace: valid_attributes }
        expect(response).to redirect_to(workplace_url(Workplace.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Workplace" do
        expect {
          post workplaces_url, params: { workplace: invalid_attributes }
        }.to change(Workplace, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post workplaces_url, params: { workplace: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: 'New Name', description: "some more textinfo" }
      }

      it "updates the requested workplace" do
        workplace = Workplace.create! valid_attributes
        patch workplace_url(workplace), params: { workplace: new_attributes }
        workplace.reload
        expect(workplace.name).to eq("New Name")
        expect(workplace.description.to_plain_text).to eq("some more textinfo")
      end

      it "redirects to the workplace" do
        workplace = Workplace.create! valid_attributes
        patch workplace_url(workplace), params: { workplace: new_attributes }
        workplace.reload
        expect(response).to redirect_to(workplace_url(workplace))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        workplace = Workplace.create! valid_attributes
        patch workplace_url(workplace), params: { workplace: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested workplace" do
      workplace = Workplace.create! valid_attributes
      expect {
        delete workplace_url(workplace)
      }.to change(Workplace, :count).by(-1)
    end

    it "redirects to the workplaces list" do
      workplace = Workplace.create! valid_attributes
      delete workplace_url(workplace)
      expect(response).to redirect_to(workplaces_url)
    end
  end
end
