class NoteMailer < ApplicationMailer
  def send_note
    @note = params[:note]
    @user = params[:user]
    mail(from: mail_from, to: @note.mail_to, subject: @note.subject)
  end

private
  def mail_from
    if @user.email.present?
      @user.email
    else
      Cocard.mail_from
    end
  end
end
