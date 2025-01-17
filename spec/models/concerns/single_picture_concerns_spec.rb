require 'rails_helper'

RSpec.describe SinglePictureConcerns, type: :model do
  let!(:sp1) {FactoryBot.create(:single_picture, availability: 1, tid: "A", muted: false)}
  let!(:sp2) {FactoryBot.create(:single_picture, availability: 1, tid: "A", muted: true)}
  let!(:sp3) {FactoryBot.create(:single_picture, availability: 0, tid: "A", muted: false)}
  let!(:sp4) {FactoryBot.create(:single_picture, availability: 0, tid: "A", muted: true)}

  describe "#availability" do
    it { expect(SinglePicture.availability(1)).to contain_exactly(sp1) }
    it { expect(SinglePicture.availability(0)).to contain_exactly(sp3) }

    it { expect(SinglePicture.ok).to contain_exactly(sp1) }
    it { expect(SinglePicture.critical).to contain_exactly(sp3) }
    it { expect(SinglePicture.failed).to contain_exactly(sp3) }
    it { expect(SinglePicture.active).to contain_exactly(sp1,sp3) }
    it { expect(SinglePicture.with_failed_tids).to contain_exactly(sp1,sp3) }
  end

end
