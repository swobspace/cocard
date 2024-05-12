require 'rails_helper'

module Cocard
  RSpec.describe Certificate, type: :model do
    let(:encoded_cert) do
"MIIFgTCCBGmgAwIBAgIDRmTbMA0GCSqGSIb3DQEBCwUAMIGJMQswCQYDVQQGEwJERTEVMBMGA1UECgwMRC1UUlVTVCBHbWJIMUgwRgYDVQQLDD9JbnN0aXR1dGlvbiBkZXMgR2VzdW5kaGVpdHN3ZXNlbnMtQ0EgZGVyIFRlbGVtYXRpa2luZnJhc3RydWt0dXIxGTAXBgNVBAMMEEQtVHJ1c3QuU01DQi1DQTMwHhcNMjIwMTE5MDgyNTUwWhcNMjYwODE1MDcyOTMxWjCBwjELMAkGA1UEBhMCREUxDzANBgNVBAcMBkFkZW5hdTEOMAwGA1UEEQwFNTM1MTgxHjAcBgNVBAkMFU3DvGhsZW5zdHJhw59lICAzMS0zNTESMBAGA1UECgwJNDc3NDEyMTAwMRAwDgYDVQQEDAdMZXBwaW5nMQ8wDQYDVQQqDAZUaG9tYXMxETAPBgNVBAwMCERyLiBtZWQuMSgwJgYDVQQDDB9JbnN0aXR1dHNhbWJ1bGFueiAtIERyLiBMZXBwaW5nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnOsctMXOOwGZaMX8GRK+O2JxwBZLDQESG4AnOViaA8JYSPnpRZXAKxXANuLhWNs9EZANwIeCqWw0LnYglgdN0re/eydWVNVzcWxkihyeOxQJ4Pk0Mt1R5F9JQ7CAtT+CMA5146mreV/oRVqS3tApD/+b8AdgLTSPl+j7Uskf/7PsqXwLicjSsNxl/OepMgtjLMSYI/qr+lxoKOvX8DOGF+JCz8wrBjJMo1af15GaQpW7qzRPn3WVoNIfJL5oljR3v1+ght7ioV9XpkoQzD5H0+3yQfDKhfrAc/KKGMm+34JFHLGXWikTzGGPS/eGlyoYME958TFl3YmBq3BAAr4AxwIDAQABo4IBtTCCAbEwHwYDVR0jBBgwFoAUxk6YSKNeL3M/yJih5vVHqDXIhTowRQYFKyQIAwMEPDA6MDgwNjA0MDIwFgwUQmV0cmllYnNzdMOkdHRlIEFyenQwCQYHKoIUAEwEMhMNMS0yMDQ3NzQxMjEwMDBEBggrBgEFBQcBAQQ4MDYwNAYIKwYBBQUHMAGGKGh0dHA6Ly9ELVRSVVNULVNNQ0ItQ0EzLm9jc3AuZC10cnVzdC5uZXQwUQYDVR0gBEowSDA7BggqghQATASBIzAvMC0GCCsGAQUFBwIBFiFodHRwOi8vd3d3LmdlbWF0aWsuZGUvZ28vcG9saWNpZXMwCQYHKoIUAEwETDBxBgNVHR8EajBoMGagZKBihmBsZGFwOi8vZGlyZWN0b3J5LmQtdHJ1c3QubmV0L0NOPUQtVHJ1c3QuU01DQi1DQTMsTz1ELVRSVVNUJTIwR21iSCxDPURFP2NlcnRpZmljYXRlcmV2b2NhdGlvbmxpc3QwHQYDVR0OBBYEFKPRn6K87Za7DJf7EWc8s/w+xiRKMA4GA1UdDwEB/wQEAwIEMDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IBAQBHmT+e+HeZnwlAIotFjEw6WOhqauUspLn1vXRKTD7T/Yvn87gQeVju6AbpxIqHB7Cka8+dXQjxe6zcwTDhnNAjQx/Tl11qSgCznDWlO5PSTyOflDoVShV91LtVToALbju2YzGhwJkEgvHCJNksga7krAm+CHJ8ib3kEf5eJ/GYp4Q73pHsAwPr3vzCNp5aYFbalfxWS6NTvy27JugY8q/xhF9XkrxA2zYJyMsoBk8QPOIj5p4BNMaPyYPg5sanEX6s2+huKVd5Qdf5r95QC4/cYbqNMtFydy2RRoxCLybzyZXe1dBC8HtZAFYYx4AWvnDY0bhcUq1u1OwapvUHaIEM"
    end

    subject { Cocard::Certificate.new(encoded_cert) }

    describe "without argument" do
      it "::new raise an KeyError" do
        expect { Cocard::Certificate.new() }.to raise_error(ArgumentError)
      end
    end

    describe "empty certificate" do
      it "returns nil" do
        expect { Cocard::Certificate.new(nil) }.to raise_error(NoMethodError)
      end
    end
   
    describe "with real certificate" do
      it { expect(subject.subject.to_utf8).to eq("CN=Institutsambulanz - Dr. Lepping,title=Dr. med.,GN=Thomas,SN=Lepping,O=477412100,street=Mühlenstraße  31-35,postalCode=53518,L=Adenau,C=DE")}
      it { expect(subject.cert).to be_kind_of(OpenSSL::X509::Certificate) }
      it { expect(subject.cn).to eq("Institutsambulanz - Dr. Lepping") }
      it { expect(subject.title).to eq("Dr. med.") }
      it { expect(subject.sn).to eq("Lepping") }
      it { expect(subject.givenname).to eq("Thomas") }
      it { expect(subject.street).to eq("Mühlenstraße  31-35") }
      it { expect(subject.postalcode).to eq("53518") }
      it { expect(subject.l).to eq("Adenau") }
      it { expect(subject.telematikid).to eq("1-20477412100") }
      it { expect(subject.o).to eq("477412100") }
    end

    describe "certificate without givenname, title and sn" do
      before(:each) do
        allow_any_instance_of(OpenSSL::X509::Name).to receive(:to_a).and_return([["CN", "nobody", 12]])
      end
      it { expect(subject.cn).to eq("nobody") }
      it { expect(subject.sn).to eq("") }
      it { expect(subject.givenname).to eq("") }
      it { expect(subject.title).to eq("") }
      it { expect(subject.postalcode).to eq("") }
      it { expect(subject.street).to eq("") }
      it { expect(subject.l).to eq("") }
      it { expect(subject.o).to eq("") }
    end

    describe "Cocard::Certificate::ATTRIBUTES" do
      it { expect(Cocard::Certificate::ATTRIBUTES).to contain_exactly(:cn, :title,
             :sn, :givenname, :street, :postalcode, :l, :telematikid, :o ) }
    end
  end
end
