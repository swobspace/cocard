require 'rails_helper'

RSpec.describe "/card_terminals", type: :request do
  let(:ts) { Time.current }
  let(:connector) { FactoryBot.create(:connector) }
  let(:location) { FactoryBot.create(:location, lid: 'AXC') }
  
  let(:valid_attributes) {
    FactoryBot.attributes_for(:card_terminal, :with_mac)
  }

  let(:invalid_attributes) {
    { mac: nil, serial: nil }
  }

  before(:each) do
    login_admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      CardTerminal.create! valid_attributes
      get card_terminals_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      card_terminal = CardTerminal.create! valid_attributes
      get card_terminal_url(card_terminal)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_card_terminal_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      card_terminal = CardTerminal.create! valid_attributes
      get edit_card_terminal_url(card_terminal)
      expect(response).to be_successful
    end
  end

  describe "POST /check" do
    context "with valid parameters" do
      it "checks" do
        card_terminal = CardTerminal.create! valid_attributes
        post check_card_terminal_url(card_terminal, format: :turbo_stream)
        expect(response.body).to be_blank
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new CardTerminal" do
        expect {
          post card_terminals_url, params: { card_terminal: valid_attributes }
        }.to change(CardTerminal, :count).by(1)
      end

      it "redirects to the created card_terminal" do
        post card_terminals_url, params: { card_terminal: valid_attributes }
        expect(response).to redirect_to(card_terminal_url(CardTerminal.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new CardTerminal" do
        expect {
          post card_terminals_url, params: { card_terminal: invalid_attributes }
        }.to change(CardTerminal, :count).by(0)
      end

    
      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post card_terminals_url, params: { card_terminal: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {{
        displayname: "Something",
        idle_message: "K123 MAC",
        location_id: location.id,
        description: "some other text",
        room: "Raum U.16",
        contact: "Der Hausmeister",
        plugged_in: "Dose P17/4, Patchfeld 5",
        ip: '127.3.4.5',
        slots: 3993,
        delivery_date: '2023-12-14',
        supplier: 'ACME Ltd',
        id_product: 'ORGA6141',
        serial: 'S11122277635',
        connector_id: connector.id,
        pin_mode: 'on_demand',
        last_ok: "",
        last_check: "",
        tag_list_input: [{value: "MyTag"}].to_json,
        firmware_version: '1.2.30'
      }}

      it "updates the requested card_terminal" do
        card_terminal = CardTerminal.create! valid_attributes.merge(
                                               last_check: Time.current,
                                               last_ok: Time.current)
        expect(card_terminal.last_check).not_to be_nil
        patch card_terminal_url(card_terminal), params: { card_terminal: new_attributes }
        card_terminal.reload
        expect(card_terminal.displayname).to eq('Something')
        expect(card_terminal.idle_message).to eq('K123 MAC')
        expect(card_terminal.location.lid).to eq('AXC')
        expect(card_terminal.description.to_plain_text).to eq('some other text')
        expect(card_terminal.room).to eq('Raum U.16')
        expect(card_terminal.contact).to eq('Der Hausmeister')
        expect(card_terminal.plugged_in).to eq('Dose P17/4, Patchfeld 5')
        expect(card_terminal.slots).to eq(3993)
        expect(card_terminal.ip).to eq('127.3.4.5')
        expect(card_terminal.delivery_date.to_s).to eq('2023-12-14')
        expect(card_terminal.supplier).to eq('ACME Ltd')
        expect(card_terminal.id_product).to eq('ORGA6141')
        expect(card_terminal.serial).to eq('S11122277635')
        expect(card_terminal.connector_id).to eq(connector.id)
        expect(card_terminal.pin_mode.to_s).to eq('on_demand')
        expect(card_terminal.last_ok).to be_nil
        expect(card_terminal.last_check).to be_nil
        expect(card_terminal.firmware_version).to eq('1.2.30')
        expect(card_terminal.tags.map(&:name)).to contain_exactly("MyTag")
      end

      it "redirects to the card_terminal" do
        card_terminal = CardTerminal.create! valid_attributes
        patch card_terminal_url(card_terminal), params: { card_terminal: new_attributes }
        card_terminal.reload
        expect(response).to redirect_to(card_terminal_url(card_terminal))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        card_terminal = CardTerminal.create!(mac: nil, serial: '12345678')
        patch card_terminal_url(card_terminal), params: { card_terminal: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    
    end
  end

  describe "POST /fetch_idle_message" do
    context "with valid parameters" do
      it "fetches idle message" do
        ct = CardTerminal.create!(valid_attributes)
        expect(CardTerminals::RMI::GetIdleMessageJob).to receive(:perform_now)
        post fetch_idle_message_card_terminal_url(ct)
        expect(response).to redirect_to(card_terminal_url(CardTerminal.last))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested card_terminal" do
      card_terminal = CardTerminal.create! valid_attributes
      expect {
        delete card_terminal_url(card_terminal)
      }.to change(CardTerminal, :count).by(-1)
    end

    it "redirects to the card_terminals list" do
      card_terminal = CardTerminal.create! valid_attributes
      delete card_terminal_url(card_terminal)
      expect(response).to redirect_to(card_terminals_url)
    end
  end
end
