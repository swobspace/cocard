class ApplicationController < ActionController::Base
  # -- breadcrumbs
  include Pagy::Method
  include Wobapphelpers::Breadcrumbs
  # before_action :add_breadcrumb_index, only: [:index]
  before_action :add_breadcrumb_index,
                :if => proc {|c| !devise_controller? && c.action_name == 'index' && c.controller_name !~ /(logs|\/)/ }

  # before_action :set_paper_trail_whodunnit

  # -- flash responder
  self.responder = Wobapphelpers::Responders
  respond_to :html, :json, :js

  helper_method :add_breadcrumb
  protect_from_forgery prepend: true

  # -- authorization
  load_and_authorize_resource unless: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from CanCan::AccessDenied, with: :access_denied


  # workaround for the 302/303 dilemma with hotwired/turbo
  # def redirect_to(url_options = {}, response_options = {})
  #   response_options[:status] ||= :see_other unless request.get?
  #   super url_options, response_options
  # end
  
  protected

  def after_sign_in_path_for(resource_or_scope)
    root_path
  end

  def access_denied(exception)
    if current_user.nil?
      redirect_to wobauth.login_path
    else
      flash.now[:error] = 'Keine Berechtigung für diese Aktion!'
      Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}" if Rails.env.development?
      respond_to do |format|
        format.js   { render 'errors/access_denied' }
        format.html do
          add_breadcrumb('Fehlerseite', '#')
          render 'errors/show_error', status: :unauthorized
        end
      end
    end
  end

  def record_not_found(exception)
    flash[:error] = exception.message
    respond_to do |format|
      format.js { render 'errors/show_error' }
      format.html do
        if @controller.respond_to? :index
          redirect_to url_for(action: 'index')
        else
          render 'errors/show_error', status: :unprocessable_entity
        end
      end
    end
  end

  def submit_parms
    %w[bci utf8 authenticity_token commit format]
  end

end
