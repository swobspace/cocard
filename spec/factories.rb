FactoryBot.define do
  sequence :aname do |n|
    "aname_#{n}"
  end

  sequence :iccsn do |n|
    "802764711#{sprintf('%08d', n)}"
  end

  sequence :macaddress do |n|
    sprintf("%012x", n)
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
    iccsn { generate(:iccsn) }
  end

  factory :card_terminal do
    ct_id { generate(:aname) }

    trait :with_mac do
      mac { generate(:macaddress) }
    end

    trait :with_sn do
      serial { generate(:aname) }
    end
  end

  factory :client_certificate do
    name { generate(:aname) }
    cert { 'nonsense'}
    pkey { 'nonsense'}
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

  factory :log do
    action { "Doit" }
    last_seen { Time.current }
    level { "INFO" }
    message { "Some informational message" }
    trait :with_connector do
      association :loggable, factory: :connector
    end
    trait :with_card_terminal do
      association :loggable, factory: :card_terminal
    end
    trait :with_card do
      association :loggable, factory: :card
    end
  end

  factory :network do
    location
  end

  factory :operational_state do
    name { generate(:aname) }
  end

  factory :workplace do
    name { generate(:aname) }
  end

  factory :terminal_workplace do
    workplace
    association :card_terminal, :with_mac
    mandant { generate(:aname) }
    client_system { generate(:aname) }
  end

end

