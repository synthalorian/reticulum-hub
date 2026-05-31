FactoryBot.define do
  factory :alert do
    alert_rule { nil }
    status { "MyString" }
    severity { "MyString" }
    message { "MyString" }
    details { "" }
    triggered_at { "2026-05-30 22:33:46" }
    acknowledged_at { "2026-05-30 22:33:46" }
    resolved_at { "2026-05-30 22:33:46" }
  end
end
