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

end
