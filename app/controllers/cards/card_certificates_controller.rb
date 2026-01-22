module Cards
  class CardCertificatesController < CardCertificatesController
    before_action :set_certable

    def fetch
      card = @certable
      if ['HBA', 'SMC-B'].include?(card.card_type)
        Cards::FetchCertificates.new(card: card).call do |result|
          result.on_success do |message, card_certificates|
            flash[:success] = "#{card.iccsn} #{card.card_type}: #{message}"
          end

          result.on_failure do |message|
            flash[:alert] = "#{card.iccsn} #{card.card_type}: #{message}"
          end
        end
      else
        flash[:warning] = "#{card.iccsn} #{card.card_type} wird nicht unterstützt!"
      end
      respond_with(@certable, location: card_path(@certable))
    end

    private

    def set_certable
      @certable = Card.find(params[:card_id])
    end

    def add_breadcrumb_show
      # add_breadcrumb_for([set_certable, @note])
    end
  end
end

