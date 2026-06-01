require 'rails_helper'

RSpec.describe "Alerts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get alerts_path
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get alerts_path
      expect(response).to render_template(:index)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      alert = create(:alert)
      get alert_path(alert)
      expect(response).to have_http_status(:success)
    end

    it "renders the show template" do
      alert = create(:alert)
      get alert_path(alert)
      expect(response).to render_template(:show)
    end
  end

  describe "POST /acknowledge" do
    it "acknowledges an alert and redirects" do
      alert = create(:alert)
      post acknowledge_alert_path(alert)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(alerts_path)
    end

    it "changes alert status to acknowledged" do
      alert = create(:alert, status: "active")
      post acknowledge_alert_path(alert)
      alert.reload
      expect(alert.status).to eq("acknowledged")
    end
  end

  describe "POST /resolve" do
    it "resolves an alert and redirects" do
      alert = create(:alert)
      post resolve_alert_path(alert)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(alerts_path)
    end

    it "changes alert status to resolved" do
      alert = create(:alert, status: "active")
      post resolve_alert_path(alert)
      alert.reload
      expect(alert.status).to eq("resolved")
    end
  end
end
