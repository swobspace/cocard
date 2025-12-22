class NoteMailer < ApplicationMailer
  def send_note
    @note = params[:note]
    mail(to: @note.mail_to, subject: @note.subject)
  end
end
