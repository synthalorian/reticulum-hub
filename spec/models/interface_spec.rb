require 'rails_helper'

RSpec.describe Interface, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:interface)).to be_valid
    end

    it "requires name" do
      expect(build(:interface, name: nil)).not_to be_valid
    end

    it "requires a valid status" do
      expect(build(:interface, status: "invalid")).not_to be_valid
      expect(build(:interface, status: "up")).to be_valid
    end
  end

  describe "#formatted_bandwidth" do
    it "formats bandwidth correctly" do
      iface = build(:interface, bandwidth_in: 1_500_000, bandwidth_out: 500_000)
      expect(iface.formatted_bandwidth).to eq("↓1.4MB ↑488.3KB")
    end
  end
end
