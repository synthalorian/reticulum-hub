FactoryBot.define do
  factory :node do
    destination_hash { "MyString" }
    name { "MyString" }
    hops { 1 }
    last_seen { "2026-05-30 22:33:50" }
    services { "" }
    metadata { "" }
  end
end
