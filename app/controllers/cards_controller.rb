class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /cards
  def index
    @cards = Card.all
    respond_with(@cards)
  end

  # GET /cards/1
  def show
    respond_with(@card)
  end

  # GET /cards/1/edit
  def edit
  end

  # PATCH/PUT /cards/1
  def update
    @card.update(card_params)
    respond_with(@card)
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

    # Only allow a trusted parameter "white list" through.
    def card_params
      params.require(:card).permit(:name, :description)
    end
end
