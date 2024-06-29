class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /cards
  def index
    if params[:card_type]
      @cards = Card.where(card_type: params[:card_type])
    else
      @cards = Card.all
    end
    respond_with(@cards)
  end

  def sindex
    if params[:condition]
      @cards = Card.condition(params[:condition])
    else
      @cards = Card.failed
    end
    @pagy, @cards = pagy(@cards)
    respond_with(@cards)
  end

  # GET /cards/1
  def show
    respond_with(@card)
  end

  # GET /cards/new
  def new
    @card = Card.new
    respond_with(@card)
  end
    
  # GET /cards/1/edit
  def edit
  end

  # POST /cards
  def create
    @card = Card.new(card_params)

    @card.save
    respond_with(@card)
  end

  # PATCH/PUT /cards/1
  def update
    @card.update(card_params)
    respond_with(@card)
  end

  def get_certificate
      result = Cocard::GetCertificate.new(card: @card).call
    unless result.success?
      @card.errors.add(:base, :invalid)
      @card.errors.add(:base, result.error_messages.join("; "))
      flash[:alert] = result.error_messages.join(', ')
    end
    respond_with(@card, action: :show)
  end

  def get_pin_status
      result = Cocard::GetPinStatus.new(card: @card, context: set_context).call
    unless result.success?
      @card.errors.add(:base, :invalid)
      @card.errors.add(:base, result.error_messages.join("; "))
      flash[:alert] = result.error_messages.join(', ')
    else
      flash[:notice] = "Kontext: #{@context}, PIN-Status: #{result.pin_status}"
    end
    respond_with(@card, action: :show)
  end

  def get_card
      result = Cocard::GetCard.new(card: @card).call
    unless result.success?
      @card.errors.add(:base, :invalid)
      @card.errors.add(:base, result.error_messages.join("; "))
      flash[:alert] = result.error_messages.join(', ')
    end
    respond_with(@card, action: :show)
  end

  # DELETE /cards/1
  def destroy
    @card.destroy!
    respond_with(@card)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    def set_context
      if params[:context_id]
        @context = Context.find(params[:context_id])
      else
        @context = @card.context
      end
    end

    # Only allow a trusted parameter "white list" through.
    def card_params
      params.require(:card)
            .permit(:name, :description, :iccsn, :slotid, :card_type, 
                    :card_holder_name, :card_terminal_id, :location_id,
                    :operational_state_id, :lanr, :bsnr, :telematikid,
                    :fachrichtung, :context_id, :private_information,
                    :cert_subject_title, :cert_subject_sn, :cert_subject_givenname,
                    :cert_subject_street, :cert_subject_postalcode, :cert_subject_l,
                    :cert_subject_o, :cert_subject_cn, :expiration_date
                   )
    end
end
