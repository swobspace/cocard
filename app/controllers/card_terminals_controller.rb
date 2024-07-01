class CardTerminalsController < ApplicationController
  before_action :set_card_terminal, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /card_terminals
  def index
    @card_terminals = CardTerminal.all
    respond_with(@card_terminals)
  end

  def sindex
    if params[:condition]
      @card_terminals = CardTerminal.condition(params[:condition])
                                    .order('updated_at desc')
    else
      @card_terminals = CardTerminal.failed
                                    .order('updated_at desc')
    end
    @pagy, @card_terminals = pagy(@card_terminals)
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

  # DELETE /card_terminals/1
  def destroy
    @card_terminal.destroy!
    respond_with(@card_terminal)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_terminal
      @card_terminal = CardTerminal.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_terminal_params
      params.require(:card_terminal)
            .permit(:displayname, :location_id, :description, :room,
                    :contact, :plugged_in, :mac, :ip, :slots, :connector_id,
                    :delivery_date, :supplier, :id_product, :serial)
            .reject { |k, v| k == 'mac' && v.blank? }

    end
end
