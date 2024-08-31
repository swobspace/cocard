require 'rails_helper'
require "cancan/matchers"

RSpec.shared_examples "an Admin" do
  it { is_expected.to be_able_to(:manage, :all) }
  it { is_expected.not_to be_able_to(:update, r_admin) }
  it { is_expected.not_to be_able_to(:destroy, Wobauth::Role.new) }
end

RSpec.describe "User", :type => :model do
  let(:r_admin) { Wobauth::Role.where(name: 'Admin').first }
  subject(:ability) { Ability.new(user) }

  context "with role Admin assigned to user" do
    let(:user) { FactoryBot.create(:user) }
    let!(:authority) {
      FactoryBot.create(:authority,
        authorizable: user,
        role: r_admin)
      }
    it_behaves_like "an Admin"
  end
end

