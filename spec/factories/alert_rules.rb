FactoryBot.define do
  factory :alert_rule do
    name { "MyString" }
    condition { "MyString" }
    threshold { 1.5 }
    notification_channels { "" }
    enabled { false }
    metadata { "" }
  end
end
