class CardsController < ApplicationController
  skip_load_and_authorize_resource
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  authorize_resource
  before_action :add_breadcrumb_show, only: [:show]

  # GET /cards
  def index
    if @locatable
      @cards = @locatable.cards
    else
      @cards = Card.all
    end

    if search_params.present?
      @cards = @cards.left_outer_joins(:location, :operational_state)
      @cards = Cards::Query.new(@cards, search_params).all
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
    if @card.card_type == 'SMC-B' and @card.contexts.empty?
      flash[:notice] = t('cards.no_contexts_assigned')
    end
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

  def copy
    card = Card.find(params[:id])
    @card = @card.dup || Card.new
    @card.iccsn = ''
    @card.operational_state_id = nil
    @card.description = card.description
    @card.private_information = card.private_information
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
        if result.pin_status&.pin_status == 'VERIFIED'
          status  = :success
        else
          status  = :warning
        end
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
    ct = @card.card_terminal
    if !set_context
      status  = :alert
      message = "No context assigned or context not found!"
    elsif ct.pin_mode == 'off'
      status  = :alert
      message = "CardTerminal #{ct} pin mode == off"
    else
      # start background rmi job
      CardTerminals::RMI::VerifyPinJob.perform_later(card: @card)
      # wait some time
      sleep 3

      # start verify pin
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
    @card.soft_delete
    respond_with(@card, location: polymorphic_path([@locatable, :cards]))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.with_deleted.find(params[:id])
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
            .permit(:name, :description, :iccsn, :card_type,
                    :card_holder_name, :location_id,
                    :operational_state_id, :lanr, :bsnr, :telematikid,
                    :fachrichtung, :context_id, :private_information,
                    :card_terminal_slot_id, :tag_list_input,
                    :cert_subject_title, :cert_subject_sn, :cert_subject_givenname,
                    :cert_subject_street, :cert_subject_postalcode, :cert_subject_l,
                    :cert_subject_o, :cert_subject_cn, :expiration_date,
                    card_contexts_attributes: [
                      :id, :context_id, :_destroy
                    ])
    end

    def search_params
      searchparms = params.permit(*submit_parms, Card.attribute_names,
                                  :description, :slotid, :expired, :outdated,
                                  :search, :operational, :operational_state, :lid,
                                  :acknowledged, :deleted, :connector_id,
                                  :limit).to_h
      searchparms.reject do |k, v|
        v.blank? || submit_parms.include?(k) || non_search_params.include?(k)
      end
    end

    def submit_parms
      [ "utf8", "authenticity_token", "commit", "format", "view" ]
    end

    def non_search_params
      [ ]
    end

end
