module TIClients
  class KTProxiesController < KTProxiesController
    before_action :set_proxyable

    def fetch
      success = true
      @kt_proxies = []
      @err_proxies = []
      rtic = RISE::TIClient::CardTerminals.new(ti_client: @proxyable)
      rtic.get_proxies do |result|
        result.on_success do |message, value|
          proxies = value['proxies'] || []
          proxies.each do |proxy|
            ktp = KTProxies::Crupdator.new(ti_client: @proxyable, proxy_hash: proxy)
            if ktp.save
              @kt_proxies << ktp.kt_proxy
            else
              success = false
              @err_proxies << proxy
            end
          end
          if success
            flash[:success] = "KT-Proxys mit Daten vom TIClient aktualisiert"
          else
            flash[:warning] = "Einige KT-Proxys konnten nicht aktualisiert werden!"
          end
        end
        result.on_failure do |message|
          flash[:alert] = message
        end
      end
      respond_with(@kt_proxies)
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

