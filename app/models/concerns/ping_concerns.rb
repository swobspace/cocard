# frozen_string_literal: true

module PingConcerns
  extend ActiveSupport::Concern

  included do
  end

  def up?
    check = Net::Ping::External.new(ip.to_s, nil, 2)
    check.ping?
  end
end
