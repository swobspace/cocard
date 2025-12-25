class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  # before_action :add_breadcrumb_show, only: [:show]

  # GET /notes
  def index
    if @notable
      @notes = @notable.notes
      @notes = @notes.active if params[:active].present?
      ordered = @notes.order('created_at DESC')
      @pagy, @notes = pagy(ordered, count: ordered.count)
    else
      @notes = Note.object_notes
      @notes = @notes.active if params[:active].present?
      @notes = @notes.order('created_at DESC')
    end

    respond_with(@notes)
  end

  def sindex
    if @notable
      @notes = @notable.notes.active
    else
      @notes = Note.object_notes.active.current
    end
    ordered = @notes.order('created_at DESC')
    @pagy, @notes = pagy(ordered, count: ordered.count)
    respond_with(@notes)
  end

  # GET /notes/1
  def show
    respond_with(@note)
  end

  # GET /notes/new
  def new
    Rails.logger.debug("DEBUG:: #{mail_params}")
    @note = @notable.notes.build({type: (params[:type] || :plain)}.merge(mail_params))
    Rails.logger.debug("DEBUG:: #{@note.inspect}")
    respond_with(@note)
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  def create
    @note = @notable.notes.build(default_note_params.merge(note_params,force_note_params))
    respond_with(@task, location: location) do |format|
      if @note.save
        format.turbo_stream { flash.now[:notice] = "Note successfully created" }
        Notes::Processor.new(note: @note).call(:create)
        if Cocard.use_mail? && @note.subject.present?
          NoteMailer.with(note: @note, user: current_user).send_note.deliver_later
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1
  def update
    respond_with(@note, location: location) do |format|
      if @note.update(note_params)
        format.turbo_stream { flash.now[:notice] = "Note successfully updated" }
        Notes::Processor.new(note: @note).call(:update)
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  def destroy
    respond_with(@note, location: location) do |format|
      if @note.destroy
        format.turbo_stream { flash.now[:notice] = "Note successfully deleted" }
        Notes::Processor.new(note: @note).call(:destroy)
      end
    end
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
      params.require(:note)
            .permit(:notable_id, :notable_type, :type, 
                    :valid_until, :message, :subject, :mail_to)
            .reject {|k,v| ['subject', 'mail_to'].include?(k) && v.blank?}
    end

    def default_note_params
      if params[:note][:type].present? 
        newtype = params[:note][:type]
      else
        newtype = :plain
      end 
      { type: newtype }
    end 
      
    def force_note_params
      {   
        user_id: current_user.id
      }   
    end 

    def mail_params
      if params[:mail]
        {
          subject: default_mail_subject,
          mail_to: default_mail_to
        }
      else
        { }
      end
    end

    def default_mail_subject
      if @notable.respond_to?(:to_subject)
        @notable.to_subject
      else
        @notable.to_s
      end
    end
        
    def default_mail_to
      Cocard.mail_to
    end

    def add_breadcrumb_index
      # skip
    end

end
