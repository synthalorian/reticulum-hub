FactoryBot.define do
  factory :system_stat do
    cpu_percent { 1.5 }
    memory_percent { 1.5 }
    bandwidth_in { 1 }
    bandwidth_out { 1 }
    uptime { 1 }
    peer_count { 1 }
    interface_count { 1 }
    metadata { "" }
  end
end
