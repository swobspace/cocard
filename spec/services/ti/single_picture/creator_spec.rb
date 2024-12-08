# frozen_string_literal: true

require 'rails_helper'
module TI::SinglePictures
  RSpec.describe Creator do
    let!(:ts) { 1.day.before(Time.current) }
    let(:json) do
      %Q[{"time":"2024-11-01T10:45:15.263Z","ci":"CI-0000456","tid":"BIT40","bu":"PU","organization":"BITMARCK Service GmbH","pdt":"PDT24","product":"Fachdienst KIM","availability":1,"comment":null,"name":"BITMARCK  Service FD KIM"}]
    end

    let(:ti_sp) { TI::SinglePicture.new(JSON.parse(json)) }


    subject { TI::SinglePictures::Creator.new(sp: ti_sp) }

    # check for instance methods
    describe 'check if instance methods exists' do
      it { expect(subject).to be_kind_of(TI::SinglePictures::Creator) }
      it { expect(subject.respond_to?(:save)).to be_truthy }
    end

    describe '#new' do
      context 'without :sp' do
        it 'raises a KeyError' do
          expect do
            Creator.new()
          end.to raise_error(KeyError)
        end
      end
    end

    describe '#save' do
      context 'new card' do
        let(:single_picture) { subject.save; subject.single_picture }
        it 'create a new single_picture' do
          expect do
            subject.save
          end.to change(SinglePicture, :count).by(1)
          expect(subject.single_picture).to be_kind_of(SinglePicture)
        end

        it { expect(single_picture.time).to eq("2024-11-01T10:45:15.263Z") }
        it { expect(single_picture.ci).to eq("CI-0000456") }
        it { expect(single_picture.tid).to eq("BIT40") }
        it { expect(single_picture.bu).to eq("PU") }
        it { expect(single_picture.organization).to eq("BITMARCK Service GmbH") }
        it { expect(single_picture.pdt).to eq("PDT24") }
        it { expect(single_picture.product).to eq("Fachdienst KIM") }
        it { expect(single_picture.availability).to eq(1) }
        it { expect(single_picture.comment).to be_nil }
        it { expect(single_picture.name).to eq("BITMARCK  Service FD KIM") }
      end

      it { expect(subject.save).to be_truthy }

      context 'with an existing single_picture' do
        let!(:single_picture) do
          FactoryBot.create(:single_picture, 
            ci: 'CI-0000456',
            tid: 'TID-1',
            bu: 'BU-2',
            organization: 'OU-3',
            pdt: 'PDT-4',
            product: 'PRODUCT-5',
            availability: 0,
            comment: 'Comment',
            name: 'NAME',
          )
        end

        # it { puts single_picture.inspect }
        it 'does not create a single_picture' do
          expect {
            subject.save
          }.to change(SinglePicture, :count).by(0)
          expect(subject.single_picture).to be_kind_of(SinglePicture)
          expect(subject.single_picture).to eq(single_picture)
        end

        it { expect(subject.save).to be_truthy }

        context 'update attributes' do
          before(:each) do
            subject.save
            single_picture.reload
          end
          it { expect(single_picture.ci).to eq("CI-0000456") }
        end
      end
    end
  end
end
