FactoryBot.define do
  sequence :aname do |n|
    "aname_#{n}"
  end

  sequence :iccsn do |n|
    "802764711#{sprintf('%08d', n)}"
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

  factory :card do
    card_terminal
    iccsn { generate(:iccsn) }
  end

  factory :card_terminal do
    connector
  end

  factory :connector do
    ip { Faker::Internet.ip_v4_address }
  end

  factory :connector_context do
    connector
    context
  end

  factory :context do
    mandant { generate(:aname) }
    client_system { generate(:aname) }
    workplace { generate(:aname) }
  end

  factory :location do
    lid { generate(:lid) }
  end

end

