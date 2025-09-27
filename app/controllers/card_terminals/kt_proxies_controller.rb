module CardTerminals
  class KTProxiesController < KTProxiesController
    before_action :set_proxyable

    private

    def set_proxyable
      @proxyable = CardTerminal.find(params[:card_terminal_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_proxyable, @note])
    end
  end
end

