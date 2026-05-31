require 'rails_helper'

RSpec.describe AlertRule, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:alert_rule)).to be_valid
    end

    it "requires name" do
      expect(build(:alert_rule, name: nil)).not_to be_valid
    end

    it "requires a valid condition" do
      expect(build(:alert_rule, condition: "invalid")).not_to be_valid
    end
  end
end
