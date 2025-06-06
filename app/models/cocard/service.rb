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

    def version(ver)
      versions.select{|v| v['version'].to_s == ver.to_s}.first
    end

    def endpoint_location(ver)
      return "" if version(ver).nil?
      version(ver)['endpoint']['@Location']
    end

    def endpoint_tls_location(ver)
      return "" if version(ver).nil?
      version(ver)['endpoint_tls']['@Location']
    end

    def target_namespace(ver)
      version(ver)['target_namespace']
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
