FactoryBot.define do
  factory :message do
    sender_hash { "<sender>" }
    recipient_hash { "<recipient>" }
    subject { "Test Message" }
    body { "Hello from Reticulum" }
    sent_at { Time.current }
    delivered { false }
    read { false }
    direction { "outbound" }
    metadata { {} }
  end
end
