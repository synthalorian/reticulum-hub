require 'rails_helper'

RSpec.describe Service, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:service)).to be_valid
    end

    it "requires service_type" do
      expect(build(:service, service_type: nil)).not_to be_valid
    end

    it "requires name" do
      expect(build(:service, name: nil)).not_to be_valid
    end
  end
end
