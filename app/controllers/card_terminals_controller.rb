class CardTerminalsController < ApplicationController
  before_action :set_card_terminal, only: [:show, :edit, :update, :destroy,
                                           :fetch_idle_message, :edit_idle_message,
                                           :update_idle_message]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /card_terminals
  def index
    if @locatable
      @card_terminals = @locatable.card_terminals
    else
      @card_terminals = CardTerminal.all
    end
    @card_terminals = @card_terminals
                      .left_outer_joins(:location, :connector, card_terminal_slots: :card)
                      .distinct

    @card_terminals = CardTerminals::Query.new(@card_terminals, search_params).all
    @filter = search_params

    respond_with(@card_terminals) do |format|
      format.json { render json: CardTerminalsDatatable.new(@card_terminals, view_context) }
    end
  end

  def sindex
    if params[:condition]
      @card_terminals = CardTerminal.condition(params[:condition])
    elsif params[:acknowledged]
      @card_terminals = CardTerminal.acknowledged
    else
      @card_terminals = CardTerminal.failed.not_acknowledged
    end
    ordered = @card_terminals.order('last_ok desc NULLS LAST')
    @pagy, @card_terminals = pagy(ordered, count: ordered.count)
    respond_with(@card_terminals)
  end

  # GET /card_terminals/1
  def show
    respond_with(@card_terminal)
  end

  def ping
    respond_with(@card_terminal) do |format|
    end
  end

  def check
    CardTerminals::ConnectivityCheckJob.perform_now(card_terminal: @card_terminal)
    respond_with(@card_terminal) do |format|
      format.turbo_stream { head :ok }
    end
  end

  # GET /card_terminals/new
  def new
    @card_terminal = CardTerminal.new
    respond_with(@card_terminal)
  end

  # GET /card_terminals/1/edit
  def edit
  end

  # POST /card_terminals
  def create
    @card_terminal = CardTerminal.new(card_terminal_params)

    @card_terminal.save
    respond_with(@card_terminal)
  end

  # PATCH/PUT /card_terminals/1
  def update
    @card_terminal.update(card_terminal_params)
    respond_with(@card_terminal)
  end

  def fetch_idle_message
    unless CardTerminals::RMI::GetIdleMessageJob.perform_now(card_terminal: @card_terminal)
      flash[:alert] = "Abfrage des Ruhebildschirms fehlgeschlagen!"
    end
    redirect_to @card_terminal
  end


  def edit_idle_message
    respond_with(@card_terminal)
  end

  def update_idle_message
    idle_message = idle_message_params['idle_message']

    @card_terminal.rmi.set_idle_message(idle_message) do |result|
      result.on_failure do |message|
        errormsg = "Setzen des Ruhebildschirms fehlgeschlagen!"
        Rails.logger.debug("DEBUG:: update_idle_message: #{errormsg}")
        flash.now[:alert] = errormsg
      end

      result.on_success do |message|
        @card_terminal.update(idle_message: idle_message)
        @card_terminal.reload
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(@card_terminal, partial: "card_terminals/show",
                                               locals: { card_terminal: @card_terminal }),
          turbo_stream.update('flash',  partial: "shared/flash_alert")
        ]
      }
    end
  end

  def reboot
    @card_terminal.rmi.reboot do |result|
      result.on_success do |message|
        flash[:success] = "Reboot gestartet"
      end

      result.on_failure do |message|
        flash[:alert] = "Reboot fehlgeschlagen: " + message
      end

      result.on_unsupported do
        flash[:warning] = "Reboot des Kartenterminals wird nicht unterstützt"
      end
    end

    respond_with(@card_terminal, action: :show)
  end


  # DELETE /card_terminals/1
  def destroy
    unless @card_terminal.destroy
      flash[:alert] = @card_terminal.errors.full_messages.join("; ")
    end
    respond_with(@card_terminal, location: polymorphic_path([@locatable, :card_terminals]))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_terminal
      @card_terminal = CardTerminal.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_terminal_params
      params.require(:card_terminal)
            .permit(:tag_list_input,
                    current_ability
                    .permitted_attributes(:update, (@card_terminal||CardTerminal.new)))
            .reject {|k,v| k == 'mac' && v.blank? }

    end

    def idle_message_params
      params.require(:card_terminal).permit(:idle_message)
    end

    def search_params
      searchparms = params.permit(*submit_parms, CardTerminal.attribute_names,
                                  :acknowledged, :with_smcb, :failed,
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
