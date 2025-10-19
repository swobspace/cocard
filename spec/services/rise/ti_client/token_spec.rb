# frozen_string_literal: true

require 'rails_helper'
module RISE
  RSpec.describe TIClient::Token do
    let(:json_token) do
      '{
        "access_token": "eyJraWQiOiJkZGUyMDZiYi1lMDgz",
        "scope": "API",
        "token_type": "Bearer",
        "expires_in": 299
      }'
    end

    subject { RISE::TIClient::Token.new(json_token) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(RISE::TIClient::Token) }
      it { expect(subject.respond_to?(:scope)).to be_truthy }
      it { expect(subject.respond_to?(:token)).to be_truthy }
      it { expect(subject.respond_to?(:token_type)).to be_truthy }
      it { expect(subject.respond_to?(:valid_until)).to be_truthy }
    end

    describe '::new' do
      context 'without argument' do
        it 'raises a KeyError' do
          expect do
            RISE::TIClient::Token.new()
          end.to raise_error(ArgumentError)
        end
      end

      context "with data" do
        it { expect(subject.scope).to eq("API") }
        it { expect(subject.token_type).to eq("Bearer") }
        it { expect(subject.token).to eq("eyJraWQiOiJkZGUyMDZiYi1lMDgz") }
        it { expect(subject.valid_until > 265.seconds.after(Time.current)).to be_truthy }
        it "set token = nil after expiration" do
          # ticltok = RISE::TIClient::Token.new(json_token) 
          token1 = subject.token
          expect(token1).to be_kind_of(String)
          travel 10.minutes
          token2 = subject.token
          expect(token2).to be_nil
        end
      end
    end
  end
end

