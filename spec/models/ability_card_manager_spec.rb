require 'rails_helper'
require "cancan/matchers"

RSpec.shared_examples "a CardManager" do
  it { is_expected.to be_able_to(:read, :all) }
  it { is_expected.to be_able_to(:navigate, :all) }
  it { is_expected.not_to be_able_to(:read, ClientCertificate.new) }
  it { is_expected.not_to be_able_to(:navigate, ClientCertificate.new) }
  it { is_expected.not_to be_able_to(:read, Connector.new, :id_contract) }
  it { is_expected.to be_able_to(:read, Card.new, :private_information) }

  it { is_expected.to be_able_to(:manage, Card.new) }
  it { is_expected.to be_able_to(:create, Card.new) }
  it { is_expected.to be_able_to(:update, Card.new) }
  it { is_expected.to be_able_to(:destroy, Card.new) }

  [ CardTerminal, Connector, Network, Location, OperationalState,
    Log, Workplace, Context, 
    TerminalWorkplace, CardContext, ConnectorContext ].each do |model|
      it { is_expected.not_to be_able_to(:manage, model.new) }
      it { is_expected.not_to be_able_to(:create, model.new) }
      it { is_expected.not_to be_able_to(:update, model.new) }
      it { is_expected.not_to be_able_to(:destroy, model.new) }
    end
  it { is_expected.not_to be_able_to(:read, VerifyPin) }
  it { is_expected.not_to be_able_to(:verify, VerifyPin) }
  it { is_expected.to be_able_to(:get_pin_status, Card.new) }
  it { is_expected.to be_able_to(:verify_pin, Card.new) }
  it { is_expected.to be_able_to(:get_certificate, Card.new) }
  it { is_expected.to be_able_to(:get_card, Card.new) }
end

RSpec.describe "User", :type => :model do
  let(:r_card_manager) { Wobauth::Role.find_or_create_by(name: 'CardManager') }
  subject(:ability) { Ability.new(user) }

  context "with role CardManager assigned to user" do
    let(:user) { FactoryBot.create(:user) }
    let!(:authority) {
      FactoryBot.create(:authority,
        authorizable: user,
        role: r_card_manager)
      }
    it_behaves_like "a CardManager"
  end
end

