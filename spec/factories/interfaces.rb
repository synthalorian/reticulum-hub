FactoryBot.define do
  factory :interface do
    sequence(:name) { |n| "Interface #{n}" }
    interface_type { "AutoInterface" }
    status { "up" }
    config { {} }
    bandwidth_in { 1_000_000 }
    bandwidth_out { 500_000 }
    error_rate { 0.001 }
    uptime { 86_400 }
    last_seen { Time.current }
    metadata { {} }
  end
end
