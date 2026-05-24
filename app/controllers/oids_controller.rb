class OidsController < ApplicationController
  before_action :set_oid, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /oids
  def index
    @oids = Oid.all
    respond_with(@oids)
  end

  # GET /oids/1
  def show
    respond_with(@oid)
  end

  # GET /oids/new
  def new
    @oid = Oid.new
    respond_with(@oid)
  end

  # GET /oids/1/edit
  def edit
  end

  # POST /oids
  def create
    @oid = Oid.new(oid_params)

    @oid.save
    respond_with(@oid)
  end

  # PATCH/PUT /oids/1
  def update
    @oid.update(oid_params)
    respond_with(@oid)
  end

  # DELETE /oids/1
  def destroy
    @oid.destroy!
    respond_with(@oid)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oid
      @oid = Oid.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def oid_params
      params.require(:oid).permit(:oid, :name, :reference)
    end
end
