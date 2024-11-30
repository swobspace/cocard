module Cocard
  #
  # Get card information per icssn
  #
  class ReadP12
    Result = ImmutableStruct.new(:success?, :error_messages, :params)

    # service = Cocard::ReadP12.new(options)
    #
    # mandantory options:
    # * :p12      - filename
    # * :exportpw - string
    #
    # returns:
    # Result.new(:success? (Boolean), :error_messages (Array), :params (Hash))
    # params = { cert: string, pkey: string, passphrase: string }
    #
    def initialize(options = {})
      options.symbolize_keys
      @p12      = String(options.fetch(:p12))
      @exportpw = options.fetch(:exportpw)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []

      if p12.blank?
        error_messages << "No p12 file specified"
      elsif !File.readable?(p12)
        error_messages << "p12 file is not readable"
      end

      if error_messages.any?
        return Result.new(success?: false, error_messages: error_messages,
                          params: {})
      end

      begin
        # 
        # try Ruby OpenSSL::PKCS12 first
        #
        pkcs12 = OpenSSL::PKCS12.new(File.read(p12), exportpw)
        cert = pkcs12.certificate.to_pem
        unsecure_key = pkcs12.key
        cipher = OpenSSL::Cipher.new 'aes-256-cbc'
        pkey = unsecure_key.private_to_pem cipher, passphrase

        Result.new(success?: true, error_messages: error_messages, 
                   params: { cert: cert, pkey: pkey, passphrase: passphrase })

      rescue OpenSSL::PKCS12::PKCS12Error
        #
        # if OpenSSL::PKCS12 fails, try openssl from cmdline with -legacy
        #
        cert = cert_from_p12(p12, exportpw)
        pkey = pkey_from_p12(p12, exportpw, passphrase)

        if cert.present? and pkey.present?
          Result.new(success?: true, error_messages: error_messages, 
                     params: { cert: cert, pkey: pkey, passphrase: passphrase })
        else 
          error_messages << "Could not parse P12 file"
          Result.new(success?: false, error_messages: error_messages, 
                     params: {})
        end
      end
    end

  private
    attr_reader :p12, :exportpw

    def passphrase
      @passphrase ||= SecureRandom.base64(42)
    end

    def cert_from_p12(p12, exportpw)
      cert = `openssl pkcs12 -in #{p12} -clcerts -nokeys -passin pass:#{exportpw} -legacy`
    end

    def pkey_from_p12(p12, exportpw, passphrase)
      pkey = `openssl pkcs12 -in #{p12} -nocerts -passin pass:#{exportpw} -passout pass:#{passphrase} -legacy`
    end

  end
end
