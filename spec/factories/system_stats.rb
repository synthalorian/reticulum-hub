FactoryBot.define do
  factory :system_stat do
    cpu_percent { 12.5 }
    memory_percent { 34.2 }
    bandwidth_in { 1_702_000 }
    bandwidth_out { 1_218_000 }
    uptime { 86_400 }
    peer_count { 4 }
    interface_count { 3 }
    metadata { { load_average: [ 0.45, 0.38, 0.42 ] } }
  end
end
