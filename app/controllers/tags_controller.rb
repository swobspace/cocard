class TagsController < ApplicationController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumb_show, only: [:show]

  # GET /tags
  def index
    @tags = Tag.all
    respond_with(@tags)
  end

  # GET /tags/1
  def show
    respond_with(@tag)
  end

  # GET /tags/new
  def new
    @tag = Tag.new
    respond_with(@tag)
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)

    @tag.save
    respond_with(@tag)
  end

  # PATCH/PUT /tags/1
  def update
    @tag.update(tag_params)
    respond_with(@tag)
  end

  # DELETE /tags/1
  def destroy
    @tag.destroy!
    respond_with(@tag)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tag_params
      params.require(:tag).permit(:name)
    end
end
