class OperationalStatesController < ApplicationController
  before_action :set_operational_state, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /operational_states
  def index
    @operational_states = OperationalState.all
    respond_with(@operational_states)
  end

  # GET /operational_states/1
  def show
    respond_with(@operational_state)
  end

  # GET /operational_states/new
  def new
    @operational_state = OperationalState.new
    respond_with(@operational_state)
  end

  # GET /operational_states/1/edit
  def edit
  end

  # POST /operational_states
  def create
    @operational_state = OperationalState.new(operational_state_params)

    @operational_state.save
    respond_with(@operational_state)
  end

  # PATCH/PUT /operational_states/1
  def update
    @operational_state.update(operational_state_params)
    respond_with(@operational_state)
  end

  # DELETE /operational_states/1
  def destroy
    @operational_state.destroy!
    respond_with(@operational_state)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operational_state
      @operational_state = OperationalState.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def operational_state_params
      params.require(:operational_state).permit(:name, :description, :operational)
    end
end
