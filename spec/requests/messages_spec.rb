require 'rails_helper'

RSpec.describe "Messages", type: :request do
  let!(:peer) { create(:peer) }

  describe "GET /index" do
    it "returns http success" do
      get messages_path
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get messages_path
      expect(response).to render_template(:index)
    end
  end

  describe "GET /show" do
    let!(:message) { create(:message) }

    it "returns http success" do
      get message_path(message)
      expect(response).to have_http_status(:success)
    end

    it "renders the show template" do
      get message_path(message)
      expect(response).to render_template(:show)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_message_path
      expect(response).to have_http_status(:success)
    end

    it "renders the new template" do
      get new_message_path
      expect(response).to render_template(:new)
    end
  end

  describe "POST /create" do
    it "creates a message and redirects" do
      post messages_path, params: { message: { recipient_hash: peer.destination_hash, subject: "Test", body: "Hello" } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(messages_path)
    end

    it "creates a message record" do
      expect {
        post messages_path, params: { message: { recipient_hash: peer.destination_hash, subject: "Test", body: "Hello" } }
      }.to change(Message, :count).by(1)
    end

    it "renders new on invalid params" do
      post messages_path, params: { message: { recipient_hash: "", subject: "", body: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end
  end
end
