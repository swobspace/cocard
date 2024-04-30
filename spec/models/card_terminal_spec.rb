require 'rails_helper'

RSpec.describe CardTerminal, type: :model do
  let(:location) { FactoryBot.create(:location, lid: 'ACX') }
  let(:ct) do
    FactoryBot.create(:card_terminal,
      name: 'ACME Term',
      location: location,
    )
  end
  it { is_expected.to belong_to(:connector) }
  it { is_expected.to belong_to(:location).optional }

  it 'should get plain factory working' do
    f = FactoryBot.create(:card_terminal)
    g = FactoryBot.create(:card_terminal)
    expect(f).to be_valid
    expect(g).to be_valid
    # expect(f).to validate_uniqueness_of(:mac)
  end

  describe "#to_s" do
    it { expect(ct.to_s).to match('ACME Term (ACX)') }
  end

  describe "on #save" do
    it "adds missing displayname" do
      ct.displayname = ''
      ct.name = "New Name"
      expect {
        ct.save 
      }.to change(ct, :displayname).to ('New Name')
    end
  end


  describe "product_information" do
    let(:prodinfo)  {{ product_information:
      {:information_date=> Time.current,
       :product_type_information=> {:product_type=>"KardTerm", :product_type_version=>"1.2.3.4"},
       :product_identification=> {
         :product_vendor_id=>"Heinrich GmbH",
         :product_code=>nil,
         :product_version=> { :local=>{:hw_version=>"5.6.7", :fw_version=>"8.9.1"}}
       },
       :product_miscellaneous=> {:product_vendor_name=>nil, :product_name=>nil}}
    }}
    before(:each) do
      ct.update(properties: prodinfo)
    end

    it { expect(ct.product_information).to be_kind_of(Cocard::ProductInformation) }
    it { expect(ct.product_information.product_type_information).to include(
           :product_type=>"KardTerm", :product_type_version=>"1.2.3.4"
         )}
  end
end
