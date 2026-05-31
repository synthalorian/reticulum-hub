require 'rails_helper'

RSpec.describe Alert, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:alert)).to be_valid
    end

    it "requires a valid status" do
      expect(build(:alert, status: "invalid")).not_to be_valid
    end

    it "requires a valid severity" do
      expect(build(:alert, severity: "invalid")).not_to be_valid
    end
  end

  describe "#acknowledge!" do
    it "updates status and timestamp" do
      alert = create(:alert, status: "active")
      alert.acknowledge!
      expect(alert.status).to eq("acknowledged")
      expect(alert.acknowledged_at).to be_present
    end
  end

  describe "#resolve!" do
    it "updates status and timestamp" do
      alert = create(:alert, status: "active")
      alert.resolve!
      expect(alert.status).to eq("resolved")
      expect(alert.resolved_at).to be_present
    end
  end
end
