module NetworkConcerns
  extend ActiveSupport::Concern

  included do
    def self.best_match(ip)
      return [] if ip.nil?
      networks = Network.
                   where("? << netzwerk", ip.to_s).
                   order(Arel.sql("masklen(netzwerk) desc"))
      if networks.any?
        masklen = networks.first.netzwerk.prefix
        networks.where("masklen(netzwerk) >= ?", masklen)
      else
        []
      end
    end

  end

  def to_cidr_s
    if netzwerk
      "#{netzwerk.to_s}/#{netzwerk.prefix}"
    else
      nil
    end
  end

end
