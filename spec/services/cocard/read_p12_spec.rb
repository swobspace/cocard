require 'rails_helper'

module Cocard
  RSpec.describe ReadP12 do
    let(:p12_file) do
      file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'demo.p12')
    end
    let(:exportpw) { 'justfortesting' }

    subject do
      Cocard::ReadP12.new(p12: p12_file, exportpw: exportpw)
    end


    it "does not raise an NotImplementedError" do
      expect { subject }.not_to raise_error
    end

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject.respond_to?(:call)).to be_truthy }
    end

    describe "with missing p12 file" do
      let(:p12_file) { nil }
      it { expect(subject.call.success?).to be_falsey }
      it { expect(subject.call.error_messages).to include("No p12 file specified") }
    end

    describe "with nonexistent p12 file" do
      let(:p12_file) do
        file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'doesnotexist')
      end
      it { expect(subject.call.success?).to be_falsey }
      it { expect(subject.call.error_messages).to include("p12 file is not readable") }
    end

    describe "with new p12 format" do
      describe '#call' do
        describe "successful call" do
          it { expect(subject.call.success?).to be_truthy }
          it { expect(subject.call.params).to be_kind_of(Hash) }

          describe 'get some information' do
            let(:params) { subject.call.params }
            it { expect(params[:cert]).to match(/BEGIN CERTIFICATE/) }
            it { expect(params[:pkey]).to match(/BEGIN ENCRYPTED PRIVATE KEY/) }
            it { expect(params[:passphrase].length).to eq(56) }
          end
        end
      end
    end

    describe "with legacy p12 format" do
      let(:p12_file) do
        file = File.join(Rails.root, 'spec', 'fixtures', 'files', 'demo-legacy.p12')
      end
      describe '#call' do
        describe "successful call" do
          it { expect(subject.call.success?).to be_truthy }
          it { expect(subject.call.params).to be_kind_of(Hash) }

          describe 'get some information' do
            let(:params) { subject.call.params }
            it { expect(params[:cert]).to match(/BEGIN CERTIFICATE/) }
            it { expect(params[:pkey]).to match(/BEGIN ENCRYPTED PRIVATE KEY/) }
            it { expect(params[:passphrase].length).to eq(56) }
          end
        end
      end
    end
  end
end
