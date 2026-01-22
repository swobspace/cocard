module CardTerminals
  class CardCertificatesController < CardCertificatesController
    before_action :set_certable

    private

    def set_certable
      @certable = CardTerminal.find(params[:card_terminal_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_certable, @note])
    end
  end
end

