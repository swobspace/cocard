class ContextsController < ApplicationController
  before_action :set_context, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /contexts
  def index
    @contexts = Context.all
    respond_with(@contexts)
  end

  # GET /contexts/1
  def show
    @cards = @context.cards.smcb.joins(:card_terminal_slot).order('card_terminal_slots.slotid')
    @connectors = @context.connectors
    respond_with(@context)
  end

  # GET /contexts/new
  def new
    @context = Context.new
    respond_with(@context)
  end

  # GET /contexts/1/edit
  def edit
  end

  # POST /contexts
  def create
    @context = Context.new(context_params)

    @context.save
    respond_with(@context)
  end

  # PATCH/PUT /contexts/1
  def update
    @context.update(context_params)
    respond_with(@context)
  end

  # DELETE /contexts/1
  def destroy
    unless @context.destroy
      flash[:alert] = @context.errors.full_messages.join("; ")
    end
    respond_with(@context)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_context
      @context = Context.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def context_params
      params.require(:context).permit(:mandant, :client_system, :workplace, :description)
    end
end
