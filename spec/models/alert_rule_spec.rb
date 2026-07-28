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
      expect(build(:alert_rule, condition: "peer_down")).to be_valid
      expect(build(:alert_rule, condition: "link_quality")).to be_valid
      expect(build(:alert_rule, condition: "interface_error")).to be_valid
      expect(build(:alert_rule, condition: "bandwidth_threshold")).to be_valid
    end

    it "requires threshold to be non-negative" do
      expect(build(:alert_rule, threshold: -1)).not_to be_valid
      expect(build(:alert_rule, threshold: 0)).to be_valid
    end
  end

  describe "scopes" do
    it "filters enabled rules" do
      enabled = create(:alert_rule, enabled: true)
      create(:alert_rule, enabled: false)
      expect(AlertRule.enabled).to eq([ enabled ])
    end
  end

  describe "associations" do
    it "has many alerts" do
      rule = create(:alert_rule)
      alert = create(:alert, alert_rule: rule)
      expect(rule.alerts).to include(alert)
    end
  end
end
