module TI
  class SinglePicture

    ATTRIBUTES = %i( time ci tid bu organization pdt product availability
                     comment name )
                     

    def initialize(hash)
      @hash = hash || {}
    end

    ATTRIBUTES.each do |attrib|
      define_method(attrib) do
        hash[attrib.to_s]
      end
    end

    def condition
      if @hash.empty?
        Cocard::States::NOTHING
      elsif availability == 1
        Cocard::States::OK
      elsif availability == 0
        Cocard::States::CRITICAL
      else
        Cocard::States::UNKNOWN
      end
    end

  private
    attr_reader :hash
  end
end
