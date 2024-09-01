require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:note) { FactoryBot.create(:note, :with_log, message: "some text") }

  it { is_expected.to belong_to(:notable) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to define_enum_for(:type).with_values(plain: 0, acknowledge: 1) }

  it 'should get plain factory working' do
    f = FactoryBot.create(:note, :with_log)
    g = FactoryBot.create(:note, :with_log)
    expect(f).to be_valid
    expect(g).to be_valid
  end

  describe "#to_s" do
    it { expect(note.to_s).to match('some text') }
  end

end
