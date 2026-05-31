require 'rails_helper'

RSpec.describe "Alerts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get alerts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      alert = create(:alert)
      get alert_path(alert)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /acknowledge" do
    it "acknowledges an alert and redirects" do
      alert = create(:alert)
      post acknowledge_alert_path(alert)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "POST /resolve" do
    it "resolves an alert and redirects" do
      alert = create(:alert)
      post resolve_alert_path(alert)
      expect(response).to have_http_status(:redirect)
    end
  end
end
