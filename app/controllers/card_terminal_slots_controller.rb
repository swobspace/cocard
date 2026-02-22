class CardTerminalSlotsController < ApplicationController
  before_action :set_card_terminal_slot, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /card_terminal_slots
  def index
    @card_terminal_slots = @card_terminal.card_terminal_slots
    respond_with(@card_terminal_slots)
  end

  # GET /card_terminal_slots/1
  def show
    respond_with(@card_terminal_slot)
  end

  # GET /card_terminal_slots/new
  def new
    @card_terminal_slot = @card_terminal.card_terminal_slots.build
    respond_with(@card_terminal_slot)
  end

  # GET /card_terminal_slots/1/edit
  def edit
    respond_with(@card_terminal_slot)
  end

  # POST /card_terminal_slots
  def create
    @card_terminal_slot = @card_terminal.card_terminal_slots.build(card_terminal_slot_params)

    if @card_terminal_slot.save
      card = Card.find(params[:card_id])
      card.update(card_terminal_slot_id: @card_terminal_slot.id)
    end
    respond_with(@card_terminal_slot, location: location)
  end

  # PATCH/PUT /card_terminal_slots/1
  def update
    if @card_terminal_slot.update(card_terminal_slot_params)
      if params[:card_id].blank?
        if @card_terminal_slot.card.present?
          @card_terminal_slot.card.update(card_terminal_slot_id: nil)
        end
      elsif params[:card_id] != @card_terminal_slot.card&.id
        card = Card.find(params[:card_id])
        ActiveRecord::Base.transaction do
          @card_terminal_slot.card&.update(card_terminal_slot_id: nil)
          card.update(card_terminal_slot_id: @card_terminal_slot.id)
        end
      end
    end
    respond_with(@card_terminal_slot, location: location)
  end

  # DELETE /card_terminal_slots/1
  def destroy
    @card_terminal_slot.destroy!
    respond_with(@card_terminal_slot, location: location)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_terminal_slot
      @card_terminal_slot = CardTerminalSlot.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def card_terminal_slot_params
      params.require(:card_terminal_slot).permit(:card_terminal_id, :slotid, :card_id)
    end

    def location
      if action_name == 'destroy'
        polymorphic_path([@card_terminal, :card_terminal_slots])
      else
        polymorphic_path([@card_terminal, @card_terminal_slot])
      end
    end
end
