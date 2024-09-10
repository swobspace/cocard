class LogsController < ApplicationController
  before_action :set_log, only: [:show, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /logs
  def index
    if @loggable
      @logs = @loggable.logs
      @logs = @logs.valid if params[:valid].present?
      @pagy, @logs = pagy(@logs)
    else
      if params[:valid]
        @logs = Log.valid
      else
        @logs = Log.all
      end
    end
    respond_with(@logs)
  end

  def sindex
    if params[:type]
      @logs = Log.where(loggable_type: params[:type]).valid.not_acknowledged
    elsif params[:acknowledged]
      @logs = Log.acknowledged 
    else
      @logs = Log.valid.not_acknowledged
    end
    @pagy, @logs = pagy(@logs)
    respond_with(@logs)
  end


  # GET /logs/1
  def show
    respond_with(@log)
  end

#  # GET /logs/new
#  def new
#    @log = Log.new
#    respond_with(@log)
#  end
#
#  # GET /logs/1/edit
#  def edit
#  end
#
#  # POST /logs
#  def create
#    @log = Log.new(log_params)
#
#    @log.save
#    respond_with(@log)
#  end
#
#  # PATCH/PUT /logs/1
#  def update
#    @log.update(log_params)
#    respond_with(@log)
#  end
#
  # DELETE /logs/1
  def destroy
    @log.destroy!
    respond_with(@log, location: polymorphic_path([@loggable, :logs]))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      @log = Log.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def log_params
      params.require(:log).permit(:loggable_id, :loggable_type, :action, :last_seen, :level, :message)
    end
end
