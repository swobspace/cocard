module Cocard
  class Service
    def initialize(hash)
      @hash = hash
    end

    def name
      hash['@Name']
    end

    def abstract
      hash['Abstract']
    end

    def plain
      hash
    end

    def versions
      _versions = hash['Versions']['Version']
      arry = ( _versions.kind_of? Hash ) ? [_versions] : _versions
      arry.map do |v|
        {}.tap do |h|
          h['version'] = v['@Version']
          h['abstract'] = v['Abstract']
          h['endpoint'] = v['Endpoint']
          h['endpoint_tls'] = v['EndpointTLS']
          h['target_namespace'] = v['@TargetNamespace']
        end
      end
    end

    def to_s
      text = <<~TOTEXT
        #{name} - #{abstract}
      TOTEXT
    end

  private
    attr_reader :hash
  end
end
