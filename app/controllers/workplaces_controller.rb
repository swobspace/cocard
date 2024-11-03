class WorkplacesController < ApplicationController
  before_action :set_workplace, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /workplaces
  def index
    if params[:outdated]
      @title = I18n.t('workplaces.outdated')
      @workplaces = outdated
    else
      @title = I18n.t('controller.workplaces')
      @workplaces = Workplace.all
    end
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

  def delete_outdated
    outdated.destroy_all
    redirect_to workplaces_path(outdated: true)
  end   

  def new_import     
  end                
      
  def import
    result = Workplaces::ImportCSV.new(import_params).call

    if result.success?
      count = result.workplaces.count
      flash[:success] = "Import successful: #{count} records imported"
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

    def outdated
      @outdated = Workplace.where("last_seen < ? or last_seen IS NULL", 7.days.before(Time.current))
    end
end
