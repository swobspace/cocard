require "rails_helper"

RSpec.describe Logs::NotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/logs/88/notes").to route_to("logs/notes#index", log_id: '88')
    end

    it "routes to #new" do
      expect(get: "/logs/88/notes/new").to route_to("logs/notes#new", log_id: '88')
    end

    it "routes to #show" do
      expect(get: "/logs/88/notes/1").to route_to("logs/notes#show", id: "1", log_id: '88')
    end

    it "routes to #edit" do
      expect(get: "/logs/88/notes/1/edit").to route_to("logs/notes#edit", id: "1", log_id: '88')
    end


    it "routes to #create" do
      expect(post: "/logs/88/notes").to route_to("logs/notes#create", log_id: '88')
    end

    it "routes to #update via PUT" do
      expect(put: "/logs/88/notes/1").to route_to("logs/notes#update", id: "1", log_id: '88')
    end

    it "routes to #update via PATCH" do
      expect(patch: "/logs/88/notes/1").to route_to("logs/notes#update", id: "1", log_id: '88')
    end

    it "routes to #destroy" do
      expect(delete: "/logs/88/notes/1").to route_to("logs/notes#destroy", id: "1", log_id: '88')
    end
  end
end
