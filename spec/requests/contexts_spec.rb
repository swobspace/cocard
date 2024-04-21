require 'rails_helper'

RSpec.describe "/contexts", type: :request do
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:context)
  }

  let(:invalid_attributes) {
    { mandant: nil }
  }

  before(:each) do
    login_admin
  end   
  
  describe "GET /index" do
    it "renders a successful response" do
      Context.create! valid_attributes
      get contexts_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      context = Context.create! valid_attributes
      get context_url(context)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_context_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      context = Context.create! valid_attributes
      get edit_context_url(context)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Context" do
        expect {
          post contexts_url, params: { context: valid_attributes }
        }.to change(Context, :count).by(1)
      end

      it "redirects to the created context" do
        post contexts_url, params: { context: valid_attributes }
        expect(response).to redirect_to(context_url(Context.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Context" do
        expect {
          post contexts_url, params: { context: invalid_attributes }
        }.to change(Context, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post contexts_url, params: { context: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        mandant: 'XYZ'
      }}

      it "updates the requested context" do
        context = Context.create! valid_attributes
        patch context_url(context), params: { context: new_attributes }
        context.reload
        expect(context.mandant).to eq('XYZ')
      end

      it "redirects to the context" do
        context = Context.create! valid_attributes
        patch context_url(context), params: { context: new_attributes }
        context.reload
        expect(response).to redirect_to(context_url(context))
      end
    end

    context "with invalid parameters" do
    
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        context = Context.create! valid_attributes
        patch context_url(context), params: { context: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested context" do
      context = Context.create! valid_attributes
      expect {
        delete context_url(context)
      }.to change(Context, :count).by(-1)
    end

    it "redirects to the contexts list" do
      context = Context.create! valid_attributes
      delete context_url(context)
      expect(response).to redirect_to(contexts_url)
    end
  end
end
