require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "returns http success" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET / (root)" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
