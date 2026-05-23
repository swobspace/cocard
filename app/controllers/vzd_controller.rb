class VZDController < ApplicationController
  skip_load_and_authorize_resource
  skip_before_action :add_breadcrumb_index

  def index
    add_breadcrumb("VZD-Suchergebnis", vzd_index_path(search_params))
    vzd = VZD::Query.new(connector: connector, client_certificate: client_certificate, 
                         search_options: search_params)
    @entries = vzd.all
  end

  def search
    add_breadcrumb("VZD-Suche", vzd_search_path)
  end

  private
    def connector
      Connector.ok.first
    end

    def client_certificate
      ClientCertificate.where(client_system: 'cocard').first
    end

    def search_params
      searchparms = params.permit(*submit_parms, VZD::Query::SEARCHES).to_h
      searchparms.reject do |k, v|
        v.blank? || submit_parms.include?(k) || non_search_params.include?(k)
      end
    end

    def submit_parms
      [ "utf8", "authenticity_token", "commit", "format", "view" ]
    end

    def non_search_params
      [ ]
    end


end
