require 'rails_helper'

RSpec.describe RnsPollJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    it "syncs peers to the database" do
      expect {
        RnsPollJob.perform_now
      }.not_to raise_error
    end

    it "syncs interfaces to the database" do
      expect {
        RnsPollJob.perform_now
      }.not_to raise_error
    end

    it "records system stats" do
      expect {
        RnsPollJob.perform_now
      }.to change(SystemStat, :count).by(1)
    end

    it "broadcasts network updates" do
      expect(ActionCable.server).to receive(:broadcast).at_least(:once)
      RnsPollJob.perform_now
    end
  end
end
