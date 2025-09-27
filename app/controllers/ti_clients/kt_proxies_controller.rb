module TIClients
  class KTProxiesController < KTProxiesController
    before_action :set_proxyable

    private

    def set_proxyable
      @proxyable = TIClient.find(params[:ti_client_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_proxyable, @note])
    end
  end
end

