class LogsController < ApplicationController
  before_action :set_log, only: [:show, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /logs
  def index
    if @loggable
      @logs = @loggable.logs
      @logs = @logs.valid if params[:valid].present?
      ordered = @logs
      @pagy, @logs = pagy(ordered, count: ordered.count)
    else
      if params[:valid]
        @logs = Log.valid
        @title = "Aktuelle Logeinträge"
      elsif params[:outdated]
        @logs = Log.valid.where("last_seen < ?", outdated)
        @title = "Veraltete Logeinträge"
      else
        @title = "Alle Logeinträge"
        @logs = Log.all
      end
    end
    respond_with(@logs)
  end

  def sindex
    if params[:type]
      @logs = Log.where(loggable_type: params[:type]).valid
    elsif params[:acknowledged]
      @logs = Log.valid.acknowledged
    else
      @logs = Log.valid.not_acknowledged
    end
    ordered = @logs
    @pagy, @logs = pagy(ordered, count: ordered.count)
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

  def delete_outdated
    @logs = Log.valid.where("last_seen < ?", outdated)
    @logs.destroy_all
    redirect_to logs_path(outdated: true)
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

    def outdated
      (2*Cocard::grace_period).before(Time.current)
    end
end
