require 'rails_helper'

RSpec.describe NetworkChannel, type: :channel do
  it "successfully subscribes" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("network_updates")
  end

  it "broadcasts updates" do
    expect {
      NetworkChannel.broadcast_update({ type: "test" })
    }.to have_broadcasted_to("network_updates").with({ type: "test" })
  end
end
