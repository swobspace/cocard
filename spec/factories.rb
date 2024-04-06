FactoryBot.define do
  sequence :aname do |n|
    "aname_#{n}"
  end

  sequence :lid do |n|
    "L#{n}"
  end

  sequence :amail do |n|
    "mail_#{n}@example.net"
  end

  sequence :url do |n|
    "tcp://#{Faker::Internet.ip_v4_address}:#{n}"
  end

  factory :client do
    name { generate(:aname) }
  end

  factory :connector do
    ip { Faker::Internet.ip_v4_address }
  end

  factory :location do
    lid { generate(:lid) }
  end

end

