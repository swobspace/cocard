require "rails_helper"

RSpec.describe NoteMailer, type: :mailer do
  let(:conn) { FactoryBot.create(:connector, name: 'AXC-17') }
  let(:note) do 
    FactoryBot.create(:note, 
      notable: conn,
      subject: conn.to_s,
      mail_to: "ticketsystem@example.org",
      message: "Some very long text stuff"
    )
  end
  let(:mail) { NoteMailer.with(note: note).send_note }

  it {puts mail.inspect }

  it "renders the header" do
    expect(Cocard).to receive(:mail_from).and_return('from@example.org')

    expect(mail.subject).to match(/AXC-17/)
    expect(mail.from).to eq(["from@example.org"])
    expect(mail.to).to eq(["ticketsystem@example.org"])
  end

  it "renders the body" do
    expect(mail.body.encoded).to match("Some very long text stuff")
  end
end
