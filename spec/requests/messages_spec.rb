require 'rails_helper'

RSpec.describe "Messages", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get messages_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_message_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a message and redirects" do
      post messages_path, params: { message: { recipient_hash: "<abc123>", subject: "Test", body: "Hello" } }
      expect(response).to have_http_status(:redirect)
    end
  end
end
