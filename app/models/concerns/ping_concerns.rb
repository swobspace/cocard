# frozen_string_literal: true

module PingConcerns
  extend ActiveSupport::Concern

  included do
  end

  def up?
    return false if noip?
    check = Net::Ping::External.new(ip.to_s, nil, 2)
    check.ping?
  end

  def noip?
    !!(ip.to_s =~ /\A127\.0\.0\./) || (ip.to_s == '0.0.0.0')
  end

end
