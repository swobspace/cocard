# Preview all emails at http://localhost:3000/rails/mailers/note_mailer
class NoteMailerPreview < ActionMailer::Preview
  def send_note_with_connector
    note = Note.where(notable_type: 'Connector').last
    NoteMailer.with(note: note, user: Wobauth::User.first).send_note
  end

  def send_note_with_card_terminal
    note = Note.where(notable_type: 'CardTerminal').last
    NoteMailer.with(note: note, user: Wobauth::User.first).send_note
  end

  def send_note_with_card
    note = Note.where(notable_type: 'Card').last
    NoteMailer.with(note: note, user: Wobauth::User.first).send_note
  end
end
