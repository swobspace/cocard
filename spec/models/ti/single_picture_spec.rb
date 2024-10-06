require 'rails_helper'

module TI
  RSpec.describe SinglePicture, type: :model do
    let!(:ts) { Time.current }
    let(:ti_hash) do
      {"time"=> ts,
      "ci"=>"CI-0000001",
      "tid"=>"BITTE",
      "bu"=>"PU",
      "organization"=>"BITMARCK Technik GmbH",
      "pdt"=>"PDT20",
      "product"=>"Fachdienste VSDM (UFS)",
      "availability"=>1,
      "comment"=>nil,
      "name"=>"Fachdienst VSDM (UFS)"}
    end

    subject { TI::SinglePicture.new(ti_hash) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { TI::SinglePicture.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty card" do
      it { expect{ TI::SinglePicture.new(nil) }.not_to raise_error }
      it { expect(TI::SinglePicture.new(nil).condition).to eq(Cocard::States::NOTHING) }
    end
   
    describe "with real data" do
      it { expect(subject.time).to eq(ts) }
      it { expect(subject.ci).to eq("CI-0000001") }
      it { expect(subject.tid).to eq("BITTE") }
      it { expect(subject.bu).to eq("PU") }
      it { expect(subject.organization).to eq("BITMARCK Technik GmbH") }
      it { expect(subject.pdt).to eq("PDT20") }
      it { expect(subject.product).to eq("Fachdienste VSDM (UFS)") }
      it { expect(subject.availability).to eq(1) }
      it { expect(subject.condition).to eq(Cocard::States::OK) }
      it { expect(subject.comment).to be_nil }
      it { expect(subject.name).to eq("Fachdienst VSDM (UFS)") }
    end

    describe "with availability 0" do
      before(:each) do
        expect(subject).to receive(:availability).at_least(:once).and_return(0)
      end
      it { expect(subject.condition).to eq(Cocard::States::CRITICAL) }
    end

    describe "TI::SinglePicture::ATTRIBUTES" do
      it { expect(TI::SinglePicture::ATTRIBUTES).to contain_exactly(
             *%i(time ci tid bu organization pdt product availability  comment name)
           ) }
    end
  end
end
