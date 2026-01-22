module CardTerminals
  class CardCertificatesController < CardCertificatesController
    before_action :set_certable

    def fetch
      # -- get Cards
      connector = ct.connector
      ctx       = connector.contexts.first
      result = Cocard::GetCards.new(connector:  connector, context: ctx,
                                    ct_id: ct.ct_id).call
      if result.success?
      else
        flash[:alert] = "Karten können nicht gelesen werden"
      end
      redirect_to :index
    end

    private

    def set_certable
      @certable = CardTerminal.find(params[:card_terminal_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_certable, @note])
    end
  end
end

