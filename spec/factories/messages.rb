FactoryBot.define do
  factory :message do
    sender_hash { "MyString" }
    recipient_hash { "MyString" }
    subject { "MyString" }
    body { "MyText" }
    sent_at { "2026-05-30 22:33:37" }
    delivered { false }
    read { false }
    direction { "MyString" }
    metadata { "" }
  end
end
