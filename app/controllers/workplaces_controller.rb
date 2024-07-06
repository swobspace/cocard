class WorkplacesController < ApplicationController
  before_action :set_workplace, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /workplaces
  def index
    @workplaces = Workplace.all
    respond_with(@workplaces)
  end

  # GET /workplaces/1
  def show
    respond_with(@workplace)
  end

  # GET /workplaces/new
  def new
    @workplace = Workplace.new
    respond_with(@workplace)
  end

  # GET /workplaces/1/edit
  def edit
  end

  # POST /workplaces
  def create
    @workplace = Workplace.new(workplace_params)

    @workplace.save
    respond_with(@workplace)
  end

  # PATCH/PUT /workplaces/1
  def update
    @workplace.update(workplace_params)
    respond_with(@workplace)
  end

  # DELETE /workplaces/1
  def destroy
    @workplace.destroy!
    respond_with(@workplace)
  end

  def new_import     
  end                
      
  def import
    result = Workplaces::ImportCSV.new(import_params).call

    if result.success?
      flash[:success] = "Import successful"
      redirect_to workplaces_path
    else
      flash[:error] = result.error_messages.join(", ")
      redirect_to workplaces_path
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workplace
      @workplace = Workplace.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def workplace_params
      params.require(:workplace).permit(:name, :description)
    end

    def import_params
      params.permit(:utf8, :authenticity_token, :file, :update_only, :force_update).to_hash
    end
end
