module Cocard
  class Certificate
    attr_reader :cert

    ATTRIBUTES = %i( cn title sn givenname street postalcode l telematikid o )

    def initialize(encoded_cert)
      @cert = OpenSSL::X509::Certificate.new(Base64.decode64(encoded_cert))
    end

    def subject
      cert.subject
    end

    def cn
      from_subject("CN")
    end

    def title
      from_subject("title")
    end

    def sn
      from_subject("SN")
    end

    def givenname
      from_subject("GN")
    end

    def l
      from_subject("L")
    end

    def postalcode
      from_subject("postalCode")
    end

    def street
      from_subject("street")
    end

    def o
      from_subject("O")
    end

    def telematikid
      entry = x509ExtAdmission.match(/registrationNumber:\s+([0-9.-]+)/)
      entry[1]
    end

  private

    def from_subject(attr)
      entry = subject.to_a.select{|a| a[0] == attr}.first
      ( entry.nil? ) ? "" : entry[1].force_encoding('UTF-8')
    end

    def x509ExtAdmission
      ext_admission = cert.extensions.select{|e| e.oid == "x509ExtAdmission"}.first
      ext_admission.value.force_encoding('UTF-8')
    end
  end
end
