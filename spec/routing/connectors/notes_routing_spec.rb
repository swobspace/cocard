require "rails_helper"

RSpec.describe Connectors::NotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/connectors/88/notes").to route_to("connectors/notes#index", connector_id: '88')
    end

    it "routes to #sindex" do
      expect(get: "/connectors/88/notes/sindex").to route_to("connectors/notes#sindex", connector_id: '88')
    end

    it "routes to #new" do
      expect(get: "/connectors/88/notes/new").to route_to("connectors/notes#new", connector_id: '88')
    end

    it "routes to #show" do
      expect(get: "/connectors/88/notes/1").to route_to("connectors/notes#show", id: "1", connector_id: '88')
    end

    it "routes to #edit" do
      expect(get: "/connectors/88/notes/1/edit").to route_to("connectors/notes#edit", id: "1", connector_id: '88')
    end


    it "routes to #create" do
      expect(post: "/connectors/88/notes").to route_to("connectors/notes#create", connector_id: '88')
    end

    it "routes to #update via PUT" do
      expect(put: "/connectors/88/notes/1").to route_to("connectors/notes#update", id: "1", connector_id: '88')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/connectors/88/notes/1").to route_to("connectors/notes#update", id: "1", connector_id: '88')
    end

    it "routes to #destroy" do
      expect(delete: "/connectors/88/notes/1").to route_to("connectors/notes#destroy", id: "1", connector_id: '88')
    end
  end
end
