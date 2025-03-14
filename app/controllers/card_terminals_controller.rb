class CardTerminalsController < ApplicationController
  before_action :set_card_terminal, only: [:show, :edit, :update, :destroy, 
                                           :fetch_idle_message, :edit_idle_message,
                                           :update_idle_message]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /card_terminals
  def index
    if @locatable
      @card_terminals = @locatable.card_terminals
    elsif params[:acknowledged]
      @card_terminals = CardTerminal.acknowledged
      @filter = { acknowledged: 1 }
    elsif params[:with_smcb]
      @card_terminals = CardTerminal.joins(:cards)
                                    .where("cards.card_type = 'SMC-B'")
      @filter = { with_smcb: 1 }
    else
      @card_terminals = CardTerminal.all
    end
    @card_terminals = @card_terminals
                      .left_outer_joins(:location, :connector, card_terminal_slots: :card)
                      .distinct
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
    respond_with(@connector) do |format|
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
    CardTerminals::RMI::GetIdleMessageJob.perform_now(card_terminal: @card_terminal)
    redirect_to @card_terminal
  end


  def edit_idle_message
    respond_with(@card_terminal)
  end

  def update_idle_message
    _rmi = CardTerminals::RMI::Base.new(card_terminal: @card_terminal)
    if (_rmi.valid)
      rmi = _rmi.rmi
      rmi.set_idle_message(idle_message_params['idle_message'])
      rmi.get_idle_message
      @card_terminal.update(idle_message: rmi.result['idle_message'])
      @card_terminal.reload
    end
    # redirect_to @card_terminal
    render turbo_stream: [
      turbo_stream.replace(@card_terminal, partial: "card_terminals/show",
                                           locals: { card_terminal: @card_terminal })
    ]

  end

  def reboot
    if @card_terminal.rebootable?
      rmi = CardTerminals::RMI::Base.new(card_terminal: @card_terminal).rmi
      result = rmi.reboot
      if result['result'] == 'success'
        flash[:success] = "Reboot gestartet"
      else
        msg = "Reboot fehlgeschlagen: " + result['failure']
        flash[:alert] = msg
      end
      Note.create(notable: @card_terminal, user: current_user, message: msg)
    else
      flash[:warning] = "Reboot des Kartenterminals wird nicht unterstützt"
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
            .permit(current_ability
                    .permitted_attributes(:update, (@card_terminal||CardTerminal.new)))
            .reject {|k,v| k == 'mac' && v.blank? }

    end

    def idle_message_params
      params.require(:card_terminal).permit(:idle_message)
    end
end
