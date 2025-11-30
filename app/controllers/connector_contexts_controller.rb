class ConnectorContextsController < ApplicationController
  before_action :set_connector_context, only: [:update]
  # before_action :add_breadcrumb_show, only: [:show]

  def update
    @connector_context.update(connector_context_params)
    # respond_with(@connector_context.connector)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connector_context
      @connector_context = ConnectorContext.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def connector_context_params
      params.require(:connector_context).permit(:position)
    end
end
