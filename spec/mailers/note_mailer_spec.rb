require "rails_helper"

RSpec.describe NoteMailer, type: :mailer do
  let(:conn) { FactoryBot.create(:connector, name: 'AXC-17') }
  let(:user) { FactoryBot.create(:user) }
  let(:note) do 
    FactoryBot.create(:note, 
      notable: conn,
      with_mail: 1,
      subject: conn.to_s,
      mail_to: "ticketsystem@example.org",
      message: "Some very long text stuff"
    )
  end
  let(:mail) { NoteMailer.with(note: note, user: user).send_note }

  describe "without user email set" do
    before(:each) do
      expect(Cocard).to receive(:mail_from).and_return('from@example.org')
      expect(user).to receive(:email).and_return(nil)
    end
    it "renders the header" do
      expect(mail.subject).to match(/AXC-17/)
      expect(mail.from).to eq(["from@example.org"])
      expect(mail.to).to eq(["ticketsystem@example.org"])
    end
  end

  describe "with user email set" do
    before(:each) do
      expect(user).to receive(:email).at_least(:once).and_return("myuser@example.net")
    end
    it "renders the header" do
      expect(mail.subject).to match(/AXC-17/)
      expect(mail.from).to eq(["myuser@example.net"])
      expect(mail.to).to eq(["ticketsystem@example.org"])
    end
  end


  it "renders the body" do
    expect(mail.body.encoded).to match("Some very long text stuff")
  end
end
