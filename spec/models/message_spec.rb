require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:message)).to be_valid
    end

    it "requires sender_hash" do
      expect(build(:message, sender_hash: nil)).not_to be_valid
    end

    it "requires recipient_hash" do
      expect(build(:message, recipient_hash: nil)).not_to be_valid
    end
  end

  describe "#conversation_key" do
    it "generates a consistent key" do
      msg = build(:message, sender_hash: "a", recipient_hash: "b")
      expect(msg.conversation_key).to eq("a:b")
    end
  end

  describe "#status_icon" do
    it "returns read icon" do
      expect(build(:message, read: true).status_icon).to eq("✓✓")
    end

    it "returns delivered icon" do
      expect(build(:message, delivered: true, read: false).status_icon).to eq("✓")
    end
  end
end
