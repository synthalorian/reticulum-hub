FactoryBot.define do
  factory :service do
    association :node
    service_type { "lxmf" }
    name { "LXMF Messaging" }
    description { "LXMF message transport service" }
    port { 8 }
    metadata { {} }
  end
end
