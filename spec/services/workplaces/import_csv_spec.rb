require 'rails_helper'

module Workplaces
  RSpec.describe ImportCSV do
    let(:csvfile) { File.join(Rails.root, 'spec', 'fixtures', 'files', 'workplace.csv') }

    # check for class methods
    it { expect(ImportCSV.respond_to? :new).to be_truthy}

    # check for instance methods
    describe "instance methods" do
      subject { ImportCSV.new(file: "") }
      it { expect(subject.respond_to? :call).to be_truthy}
      it { expect(subject.call.respond_to? :success?).to be_truthy }
      it { expect(subject.call.respond_to? :error_messages).to be_truthy }
      it { expect(subject.call.respond_to? :workplaces).to be_truthy }
    end

    describe "#call" do
      subject { ImportCSV.new(file: csvfile, update_only: false, force_update: true ) }

      context "with valid import_attributes" do
        it "creates a Workplace" do
          expect {
            subject.call
          }.to change(Workplace, :count).by(1)
        end

        describe "#call" do
          let(:result) { subject.call }
          it { expect(result.success?).to be_truthy }
          it { expect(result.error_messages.present?).to be_falsey }
          it { expect(result.workplaces).to be_a_kind_of Array }

          describe "the first workplace" do
            let(:wp) { result.workplaces.first }
            it { expect(wp).to be_a_kind_of Workplace }
            it { expect(wp).to be_persisted }
            it { expect(wp.name).to eq("NCC-1704") }
            it { expect(wp.description.to_plain_text).to eq("Quadrant Delta Four") }
          end
        end
      end
      describe "#with invalid csv" do
        subject { ImportCSV.new(file: "" ) }
        let(:result) { subject.call }
        it { expect(result.success?).to be_falsey }
        it { expect(result.error_messages).to contain_exactly("File  is not readable or does not exist") }
      end
    end
  end
end
