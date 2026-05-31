FactoryBot.define do
  factory :peer do
    destination_hash { "MyString" }
    name { "MyString" }
    last_seen { "2026-05-30 22:33:25" }
    link_quality { 1.5 }
    hops { 1 }
    status { "MyString" }
    metadata { "" }
  end
end
