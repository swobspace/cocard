class Rss::NotesController < NotesController
  # skip_before_action :authenticate_user!
  skip_load_and_authorize_resource
  # skip_authorization_check
  respond_to :xml
end
