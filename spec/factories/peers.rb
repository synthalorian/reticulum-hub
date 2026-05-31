FactoryBot.define do
  factory :peer do
    sequence(:destination_hash) { |n| "<peer#{n}>" }
    name { "Test Peer" }
    last_seen { 5.minutes.ago }
    link_quality { 0.85 }
    hops { 1 }
    status { "active" }
    metadata { {} }
  end
end
