module CardTerminals
  class CardCertificatesController < CardCertificatesController
    before_action :set_certable

    def fetch
      # -- get Cards
      connector = @certable.connector
      ctx       = connector.contexts.first
      result = Cocard::GetCards.new(connector:  connector, context: ctx,
                                    ct_id: @certable.ct_id).call
      if result.success?
        cards = []
        result.cards.each do |cc|
          creator = Cards::Creator.new(connector: connector, cc: cc, context: ctx)
          if creator.save
            cards << creator.card
          end
        end
        ok_msgs = []
        err_msgs = []
        cards.each do |card|
          next unless card.certable?
          Cards::FetchCertificates.new(card: card).call do |result|
            result.on_success do |message, card_certificates|
              ok_msgs << "#{card.iccsn} #{card.card_type}: #{message}"
            end

            result.on_failure do |message|
              err_msgs << "#{card.iccsn} #{card.card_type}: #{message}"
            end
          end
        end
        flash[:success] = ok_msgs.join("; ") if ok_msgs.any?
        flash[:alert] = err_msgs.join("; ") if err_msgs.any?
      else
        flash[:alert] = "Karten können nicht gelesen werden"
      end
      redirect_to card_terminal_card_certificates_path(@certable)
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

