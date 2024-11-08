class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /cards
  def index
    if @locatable
      @cards = @locatable.cards
    elsif params[:acknowledged]
      @cards = Card.acknowledged
    else
      @cards = Card.all
    end

    if params[:card_type]
      @cards = @cards.where(card_type: params[:card_type])
    end
    respond_with(@cards)
  end

  def sindex
    if params[:condition]
      @cards = Card.condition(params[:condition])
    elsif params[:acknowledged]
      @cards = Card.acknowledged
    else
      @cards = Card.failed.not_acknowledged
    end
    ordered = @cards
    @pagy, @cards = pagy(ordered, count: ordered.count)
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
    if set_context
      result = Cocard::GetPinStatus.new(card: @card, context: set_context).call
      unless result.success?
        status  = :alert
        message = (@card.to_s + "<br/>" +
                   "Kontext: #{@context}<br/>ERROR:: " +
                   result.error_messages.join(', ')).html_safe
      else
        status  = :success
        message = "Kontext: #{@context}, " +
                  "PIN-Status: #{result.pin_status.pin_status}, " +
                  "left_tries: #{result.pin_status.left_tries}"
      end
    else
      status  = :alert
      message = "No context assigned or context not found!"
    end
    render turbo_stream: [
      turbo_stream.prepend("toaster", partial: "shared/turbo_toast",
                                      locals: {status: status, message: message}),
      turbo_stream.replace(@card, partial: "cards/show",
                                      locals: { card: @card })
    ]
  end

  def verify_pin
    if set_context
      result = Cocard::VerifyPin.new(card: @card, context: set_context).call
      unless result.success?
        status  = :alert
        message = (@card.to_s + "<br/>" +
                            "Kontext: #{@context}<br/>ERROR:: " +
                            result.error_messages.join(', ')).html_safe
      else
        status  = :success
        message = (@card.to_s + "<br/>" + "Kontext: #{@context}<br/>" +
                   "VERIFY PIN successful").html_safe
      end
    else
      status  = :alert
      message = "No context assigned or context not found!"
    end
    @card.save
    render turbo_stream: [
      turbo_stream.prepend("toaster", partial: "shared/turbo_toast",
                                      locals: {status: status, message: message}),
      turbo_stream.replace(@card, partial: "cards/show",
                                      locals: { card: @card })
    ]
  end

  def get_card
      result = Cocard::GetCard.new(card: @card, context: set_context).call
      unless result.success?
        status  = :alert
        message = "Kontext: #{@context} / ERROR:: " + result.error_messages.join(', ')
      else
        status  = :success
        message = "Karte im Kontext: #{@context} aktualisiert"
    end
    @card.save
    render turbo_stream: [
      turbo_stream.prepend("toaster", partial: "shared/turbo_toast",
                                      locals: { status: status, message: message }),
      turbo_stream.replace(@card, partial: "cards/show",
                                      locals: { card: @card })
    ]
  end

  # DELETE /cards/1
  def destroy
    @card.destroy!
    respond_with(@card, location: polymorphic_path([@loggable, :cards]))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    def set_context
      @context ||= if params[:context_id]
                     Context.find(params[:context_id])
                   else
                     nil
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
                    :cert_subject_o, :cert_subject_cn, :expiration_date,
                    card_contexts_attributes: [
                      :id, :context_id, :_destroy
                    ])
    end
end
