module TIClients
  class KTProxiesController < KTProxiesController
    before_action :set_proxyable

    def fetch
      rtic = RISE::TIClient.new(ti_client: @proxyable)
      proxies = rtic.get_card_terminal_proxies['proxies'] || []
    end

    private

    def set_proxyable
      @proxyable = TIClient.find(params[:ti_client_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_proxyable, @note])
    end
  end
end

