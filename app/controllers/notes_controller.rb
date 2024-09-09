class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  # before_action :add_breadcrumb_show, only: [:show]

  # GET /notes
  def index
    @notes = @notable.notes
    @notes = @notes.active if params[:active].present?
    @pagy, @notes = pagy(@notes)

    respond_with(@notes)
  end

  # GET /notes/1
  def show
    respond_with(@note)
  end

  # GET /notes/new
  def new
    @note = @notable.notes.build(type: params[:type].to_i || Note.types[:plain])
    respond_with(@note)
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  def create
    @note = @notable.notes.build(default_note_params.merge(note_params,force_note_params))
    if @note.save
      Turbo::StreamsChannel.broadcast_refresh_to(:home)
    else
      render :new, status: :unprocessable_entity 
    end
  end

  # PATCH/PUT /notes/1
  def update
    if @note.update(note_params)
      Turbo::StreamsChannel.broadcast_refresh_to(:home)
    else
      render :edit, status: :unprocessable_entity 
    end
  end

  # DELETE /notes/1
  def destroy
    @note.destroy!
    respond_with(@note, location: location)
    # Turbo::StreamsChannel.broadcast_refresh_to(@notable)
  end

  protected
    def set_notable
      raise "set_notable must be set from submodule"
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    def location
      polymorphic_path([@notable, :notes])
      # polymorphic_path(@notable, anchor: 'notes')
    end

    # Only allow a trusted parameter "white list" through.
    def note_params
      params.require(:note).permit(:notable_id, :notable_type, :valid_until, :message)
    end

    def default_note_params
      if params[:note][:type].present? 
        newtype = params[:note][:type].to_i
      else
        newtype = Note.types[:plain]
      end 
      { type: newtype }
    end 
      
    def force_note_params
      {   
        user_id: @current_user.id
      }   
    end 

end
