require 'rails_helper'

RSpec.describe Log, type: :model do
  let!(:ts) { Time.current }
  let(:conn) { FactoryBot.create(:connector, name: 'TK-AXC-04') }
  let(:log) do 
    FactoryBot.create(:log,
      loggable: conn,
      action: 'GetCard',
      last_seen: ts,
      level: 'WARN',
      message: "A warning message"
    )
  end
  it { is_expected.to belong_to(:loggable) }
  it { is_expected.to belong_to(:acknowledge).optional }
  it { is_expected.to have_many(:notes).dependent(:destroy) }
  it { is_expected.to have_many(:plain_notes).dependent(:destroy) }
  it { is_expected.to have_many(:acknowledges).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:action) }
  it { is_expected.to validate_presence_of(:last_seen) }
  it { is_expected.to validate_presence_of(:level) }
  it { is_expected.to validate_presence_of(:message) }


  it 'should get plain factory working' do
    f = FactoryBot.create(:log, :with_connector)
    g = FactoryBot.create(:log, :with_connector)
    expect(f).to be_valid
    expect(g).to be_valid
  end

  describe "#to_s" do
    it { expect(log.to_s).to match("WARN - TK-AXC-04 >> GetCard: A warning message") }
  end

  describe "#notes" do
    let(:log) { FactoryBot.create(:log, :with_connector) }

    let!(:note) { FactoryBot.create(:note, notable: log, type: Note.types[:plain]) }
    let!(:ack) { FactoryBot.create(:note, notable: log, type: Note.types[:acknowledge]) }
    let!(:oldnote) do
      FactoryBot.create(:note, 
        notable: log, 
        type: Note.types[:plain],
        valid_until: Date.yesterday
      )
    end
    let!(:oldack) do
      FactoryBot.create(:note, 
        notable: log, 
        type: Note.types[:acknowledge],
        valid_until: Date.yesterday
      )
    end

    it { expect(log.acknowledges).to contain_exactly(ack, oldack) }
    it { expect(log.current_acknowledge).to eq(ack) }
    it { expect(log.acknowledges.active).to contain_exactly(ack) }
    it { expect(log.acknowledges.count).to eq(2) }
    it { expect(log.current_note).to eq(note) }
    it { expect(log.notes.active).to contain_exactly(note, ack) }
    it { expect(log.notes.count).to eq(4) }
    it { expect(log.plain_notes).to contain_exactly(note, oldnote) }
    it { expect(log.plain_notes.active).to contain_exactly(note) }
    it { expect(log.plain_notes.count).to eq(2) }
  end

end
