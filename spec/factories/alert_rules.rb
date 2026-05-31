FactoryBot.define do
  factory :alert_rule do
    name { "Peer Down Alert" }
    condition { "peer_down" }
    threshold { 1.0 }
    notification_channels { ["webhook"] }
    enabled { true }
    metadata { {} }
  end
end
