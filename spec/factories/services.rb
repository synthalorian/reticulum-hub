FactoryBot.define do
  factory :service do
    node { nil }
    service_type { "MyString" }
    name { "MyString" }
    description { "MyString" }
    port { 1 }
    metadata { "" }
  end
end
