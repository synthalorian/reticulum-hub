require 'rails_helper'

RSpec.describe Peer, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:peer)).to be_valid
    end

    it "requires destination_hash" do
      expect(build(:peer, destination_hash: nil)).not_to be_valid
    end

    it "requires a valid status" do
      expect(build(:peer, status: "invalid")).not_to be_valid
      expect(build(:peer, status: "active")).to be_valid
    end
  end

  describe "scopes" do
    it "filters active peers" do
      active = create(:peer, status: "active")
      create(:peer, status: "offline")
      expect(Peer.active).to eq([active])
    end
  end

  describe "#quality_color" do
    it "returns green for high quality" do
      expect(build(:peer, link_quality: 0.9).quality_color).to eq("green")
    end

    it "returns red for low quality" do
      expect(build(:peer, link_quality: 0.3).quality_color).to eq("red")
    end
  end
end
