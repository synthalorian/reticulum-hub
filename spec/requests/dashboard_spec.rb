require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "returns http success" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "renders the dashboard template" do
      get dashboard_path
      expect(response).to render_template(:index)
    end

    it "assigns peers" do
      get dashboard_path
      expect(assigns(:peers)).not_to be_nil
    end

    it "assigns interfaces" do
      get dashboard_path
      expect(assigns(:interfaces)).not_to be_nil
    end

    it "assigns stats" do
      get dashboard_path
      expect(assigns(:stats)).not_to be_nil
    end
  end

  describe "GET / (root)" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to dashboard" do
      get root_path
      expect(response).to render_template("dashboard/index")
    end
  end
end
