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
      @p12      = options.fetch(:p12)
      @exportpw = options.fetch(:exportpw)
    end

    # service.call()
    # do all the work here ;-)
    def call
      error_messages = []
      if p12.blank?
        error_messages << "No P12-File specified"
      end
      if error_messages.any?
        return Result.new(success?: false, error_messages: error_messages,
                          params: {})
      end

      begin
        pkcs12 = OpenSSL::PKCS12.new(File.read(p12), exportpw)
        cert = pkcs12.certificate.to_pem
        unsecure_key = pkcs12.key
        cipher = OpenSSL::Cipher.new 'aes-256-cbc'
        passphrase = SecureRandom.base64(42)
        pkey = unsecure_key.private_to_pem cipher, passphrase

        Result.new(success?: true, error_messages: error_messages, 
                   params: { cert: cert, pkey: pkey, passphrase: passphrase })

      rescue OpenSSL::PKCS12::PKCS12Error
        error_messages << "Could not parse P12 file"
        Result.new(success?: false, error_messages: error_messages, 
                   params: {})
      end
    end

  private
    attr_reader :p12, :exportpw

  end
end
