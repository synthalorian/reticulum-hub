FactoryBot.define do
  factory :node do
    sequence(:destination_hash) { |n| "<node#{n}>" }
    name { "Test Node" }
    hops { 1 }
    last_seen { 5.minutes.ago }
    services { [] }
    metadata { {} }
  end
end
