require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:note) { FactoryBot.create(:note, :with_log, message: "some text") }
  let(:log)  { FactoryBot.create(:log, :with_connector) }
  let(:conn) { FactoryBot.create(:connector) }

  it { is_expected.to belong_to(:notable) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to define_enum_for(:type).with_values(plain: 0, acknowledge: 1) }
  it { is_expected.to validate_presence_of(:message) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:note, :with_log)
    g = FactoryBot.create(:note, :with_log)
    expect(f).to be_valid
    expect(g).to be_valid
  end

  describe "#to_s" do
    it { expect(note.to_s).to match('some text') }
  end

  describe "#active" do

    let!(:note) { FactoryBot.create(:note, notable: log, type: Note.types[:plain]) }
    let!(:ack) { FactoryBot.create(:note, notable: log, type: Note.types[:acknowledge]) }
    let!(:oldack) do
      FactoryBot.create(:note, 
        notable: log, 
        type: Note.types[:acknowledge],
        valid_until: Date.yesterday
      )
    end

    it {expect(Note.active).to contain_exactly(note, ack) }
  end

  describe "#object_notes" do
    let!(:log_note) { FactoryBot.create(:note, notable: log) }
    let!(:conn_note) { FactoryBot.create(:note, notable: conn) }

    it { expect(Note.object_notes).to contain_exactly(conn_note) }
  end

  describe "with_mail" do
    let(:user) { FactoryBot.create(:user) }
    context "== 1" do
      it "checks for subject and mail_to" do
        note = FactoryBot.build(:note, :with_connector, user: user, with_mail: 1)
        expect {
          note.save
        }.not_to change(Note, :count)
      end
    end

    context "== 0" do
      it "clears subject and mail_to" do
        note = FactoryBot.build(:note, :with_connector, user: user, with_mail: 0,
                                subject: "Some Stuff", mail_to: "anybody@example.com")
        note.save
        note.reload
        expect(note.subject).to be_blank
        expect(note.mail_to).to be_blank
        
      end
    end
  end
end
