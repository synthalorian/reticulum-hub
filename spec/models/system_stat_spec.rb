require 'rails_helper'

RSpec.describe SystemStat, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:system_stat)).to be_valid
    end

    it "rejects cpu_percent above 100" do
      expect(build(:system_stat, cpu_percent: 101)).not_to be_valid
    end

    it "rejects negative memory_percent" do
      expect(build(:system_stat, memory_percent: -1)).not_to be_valid
    end
  end

  describe "#formatted_uptime" do
    it "formats uptime with days, hours, minutes" do
      stat = build(:system_stat, uptime: 90_061) # 1d 1h 1m 1s
      expect(stat.formatted_uptime).to eq("1d 1h 1m")
    end
  end
end
