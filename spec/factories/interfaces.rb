FactoryBot.define do
  factory :interface do
    name { "MyString" }
    interface_type { "MyString" }
    status { "MyString" }
    config { "" }
    bandwidth_in { 1 }
    bandwidth_out { 1 }
    error_rate { 1.5 }
    uptime { 1 }
    last_seen { "2026-05-30 22:33:29" }
    metadata { "" }
  end
end
