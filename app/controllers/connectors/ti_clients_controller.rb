module Connectors
  class TIClientsController < TIClientsController
    before_action :set_connector

    private

    def set_connector
      @connector = Connector.find(params[:connector_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_notable, @note])
    end
  end
end

