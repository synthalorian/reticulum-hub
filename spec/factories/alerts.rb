FactoryBot.define do
  factory :alert do
    association :alert_rule
    status { "active" }
    severity { "warning" }
    message { "Test alert message" }
    details { {} }
    triggered_at { Time.current }
    acknowledged_at { nil }
    resolved_at { nil }
  end
end
