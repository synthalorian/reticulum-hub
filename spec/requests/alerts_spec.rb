require 'rails_helper'

RSpec.describe "Alerts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/alerts/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/alerts/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /acknowledge" do
    it "returns http success" do
      get "/alerts/acknowledge"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /resolve" do
    it "returns http success" do
      get "/alerts/resolve"
      expect(response).to have_http_status(:success)
    end
  end

end
