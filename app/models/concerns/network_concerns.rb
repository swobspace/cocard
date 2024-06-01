module NetworkConcerns
  extend ActiveSupport::Concern

  included do
  end

  def to_cidr_s
    if netzwerk
      "#{netzwerk.to_s}/#{netzwerk.prefix}"
    else
      nil
    end
  end

end
