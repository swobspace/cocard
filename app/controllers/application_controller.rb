class ApplicationController < ActionController::Base
  # -- breadcrumbs
  include Wobapphelpers::Breadcrumbs
  before_action :add_breadcrumb_index, only: [:index]
  # before_action :set_paper_trail_whodunnit

  # -- flash responder
  self.responder = Wobapphelpers::Responders
  respond_to :html, :json, :js

  helper_method :add_breadcrumb
  protect_from_forgery prepend: true
end
