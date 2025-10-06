require 'rails_helper'
require "cancan/matchers"

RSpec.shared_examples "a ConnectorManager" do
  it { is_expected.to be_able_to(:read, :all) }
  it { is_expected.to be_able_to(:navigate, :all) }
  it { is_expected.to be_able_to(:failed, SinglePicture) }
  it { is_expected.not_to be_able_to(:read, ClientCertificate.new) }
  it { is_expected.not_to be_able_to(:navigate, ClientCertificate.new) }
  it { is_expected.to be_able_to(:read, Connector.new, :id_contract) }
  it { is_expected.not_to be_able_to(:read, Card.new, :private_information) }
  it { is_expected.not_to be_able_to(:read, DuckTerminal.new) }

  it { is_expected.to be_able_to(:manage, Connector.new) }
  it { is_expected.to be_able_to(:create, Connector.new) }
  it { is_expected.to be_able_to(:update, Connector.new) }
  it { is_expected.to be_able_to(:destroy, Connector.new) }
  it { is_expected.to be_able_to(:reboot, Connector.new) }
  it { is_expected.to be_able_to(:reboot, CardTerminal.new) }
  it { is_expected.to be_able_to(:remote_pairing, CardTerminal.new) }

  [ CardTerminal, Card, Network, Location, OperationalState,
    Log, Workplace, Context, ClientCertificate,
    TerminalWorkplace, CardContext, ConnectorContext ].each do |model|
      it { is_expected.not_to be_able_to(:manage, model.new) }
      it { is_expected.not_to be_able_to(:create, model.new) }
      it { is_expected.not_to be_able_to(:update, model.new) }
      it { is_expected.not_to be_able_to(:destroy, model.new) }
    end

  it { is_expected.not_to be_able_to(:read, VerifyPin) }
  it { is_expected.not_to be_able_to(:verify, VerifyPin) }
  it { is_expected.not_to be_able_to(:get_pin_status, Card.new) }
  it { is_expected.not_to be_able_to(:verify_pin, Card.new) }
  it { is_expected.not_to be_able_to(:get_certificate, Card.new) }
  it { is_expected.not_to be_able_to(:get_card, Card.new) }

  it { is_expected.to be_able_to(:create, Note) }
  it { is_expected.to be_able_to(:update, Note.new(notable_type: 'Log')) }
  it { is_expected.not_to be_able_to(:update, Note.new(notable_type: 'Card')) }
  it { is_expected.not_to be_able_to(:update, Note.new(notable_type: 'CardTerminal')) }
  it { is_expected.to be_able_to(:update, Note.new(notable_type: 'Connector')) }
  it { is_expected.to be_able_to(:destroy, Note.new(notable_type: 'Log')) }
  it { is_expected.not_to be_able_to(:destroy, Note.new(notable_type: 'Card')) }
  it { is_expected.not_to be_able_to(:destroy, Note.new(notable_type: 'CardTerminal')) }
  it { is_expected.to be_able_to(:destroy, Note.new(notable_type: 'Connector')) }
end

RSpec.describe "User", :type => :model do
  let(:r_connector_manager) { Wobauth::Role.find_or_create_by(name: 'ConnectorManager') }
  subject(:ability) { Ability.new(user) }

  context "with role ConnectorManager assigned to user" do
    let(:user) { FactoryBot.create(:user) }
    let!(:authority) {
      FactoryBot.create(:authority,
        authorizable: user,
        role: r_connector_manager)
      }
    it_behaves_like "a ConnectorManager"
  end
end

