# frozen_string_literal: true

require 'rails_helper'
module RISE
  RSpec.describe TIClient::Base do
    let(:tic) do
      FactoryBot.create(:ti_client,
        name: "TIC01",
        url: ENV['TIC_URL']
      )
    end

    let(:json_token) do
      '{
        "access_token": "eyJraWQiOiJkZGUyMDZiYi1lMDgz",
        "scope": "API",
        "token_type": "Bearer",
        "expires_in": 299
      }'
    end

    subject { RISE::TIClient::Base.new(ti_client: tic) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::Base) }
      it { expect(subject.respond_to?(:ti_client)).to be_truthy }
      it { expect(subject.respond_to?(:api_token)).to be_truthy }
      it { expect(subject.respond_to?(:authorization)).to be_truthy }
      it { expect(subject.respond_to?(:authenticate)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::Base.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#authenticate' do
      let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
      let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
      let(:auth_param) {{
        client_id: tic.client_id,
        client_secret: tic.client_secret,
        scope: 'API',
        grant_type: 'client_credentials'
      }}

      before(:each) do
        allow(Faraday).to receive(:new).and_return(conn)
      end

      after(:each) do
        Faraday.default_connection = nil
      end

      it "success: gets bearer token" do
        stubs.post('oauth2/token', auth_param) do
          [
            200, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            json_token
          ]
        end

        expect(subject.authorization).to be_kind_of(RISE::TIClient::Token)
        expect(subject.api_token).to eq("eyJraWQiOiJkZGUyMDZiYi1lMDgz")
      end

      it "failure: no bearer token" do
        stubs.post('oauth2/token', auth_param) do
          [
            401, 
            {'Content-Type': 'application/json;charset=UTF-8'},
            '{ "error": "invalid_client" }'
          ]
        end

        expect(subject.authorization).to be_nil
        expect(subject.api_token).to be_nil
      end
    end

  end
end

