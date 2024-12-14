require 'rails_helper'

module TI
  module SituationPicture
    RSpec.describe Fetch do
      Fake = Struct.new(:headers, :success?, :status, :body)
      let(:conn) { instance_double(Faraday::Connection) }
      let(:lagebild) do
        File.read(Rails.root.join('spec', 'fixtures', 'files', 'ti_lagebild.yaml'))
      end

      subject { TI::SituationPicture::Fetch.new() }


      # check for instance methods
      describe 'check if instance methods exists' do
        it { expect(subject.respond_to?(:call)).to be_truthy }
      end

      describe '#call with status 200' do
        let!(:result) { subject.call }
        it { expect(result.success?).to be_truthy }
        it { expect(result.respond_to?(:error_messages)).to be_truthy }
        it { expect(result.respond_to?(:situation_picture)).to be_truthy }
        it { expect(result.error_messages.present?).to be_falsey }
        it { expect(result.situation_picture).to be_present }
        it { expect(result.situation_picture.first).to be_kind_of(TI::SinglePicture) }
      end

      describe 'with status 500' do
        before(:each) do
          allow(Faraday).to receive(:new).and_return(conn)
        end

        let(:result) { subject.call }
        let(:fake) do
          Fake.new(['nonsense'], false, 500, 'no information available')
        end

        before(:each) do
          expect(conn).to receive(:get).with(any_args).and_return(fake)
        end

        it { expect(result.success?).to be_falsey }
        # it { puts result.error_messages }
        it { expect(result.error_messages).to include('no information available') }
        it { expect(result.situation_picture).to be_nil }

      end
    end
  end
end
