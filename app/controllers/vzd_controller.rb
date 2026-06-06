class VZDController < ApplicationController
  skip_load_and_authorize_resource
  skip_before_action :add_breadcrumb_index

  def index
    add_breadcrumb("VZD-Suchergebnis", vzd_index_path(search_params))
    vzd = VZD::Query.new(connector: connector, client_certificate: client_certificate, 
                         search_options: search_params)
    if vzd.success?
      @entries = vzd.all
    else
      @entries = []
      # @errors = vzd.errors
      flash.now[:alert] = vzd.errors.join("; ")
    end
  end

  def search
    add_breadcrumb("VZD-Suche", vzd_search_path)
    @info = "Konnektor: #{connector}, Client: #{connector&.contexts&.first&.client_system ||'Kein Kontext zugewiesen'}, Clientzertifikat: #{client_certificate || 'Zertifikat fehlt'}"
    unless config_ok?
      flash[:alert] = "Keine Suche möglich, bitte die Konfiguration überprüfen: " + @info
    end
  end

  private
    def connector
      Cocard.vzd_connector || Connector.ok.first
    end

    def client_certificate
      client_system = connector&.contexts&.first&.client_system
      connector&.client_certificate(client_system)
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

    def config_ok?
      connector.present? && client_certificate.present?
    end

end
