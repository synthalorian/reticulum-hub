require 'rails_helper'

RSpec.describe Node, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:node)).to be_valid
    end

    it "requires destination_hash" do
      expect(build(:node, destination_hash: nil)).not_to be_valid
    end
  end

  describe "#formatted_hops" do
    it "returns local for 0 hops" do
      expect(build(:node, hops: 0).formatted_hops).to eq("local")
    end

    it "returns hop count" do
      expect(build(:node, hops: 3).formatted_hops).to eq("3 hops")
    end
  end
end
