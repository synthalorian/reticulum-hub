require 'rails_helper'

RSpec.describe "Announces", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get announces_path
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get announces_path
      expect(response).to render_template(:index)
    end
  end

  describe "POST /create" do
    it "redirects to explorer" do
      post announces_path, params: { name: "Test Service", service_type: "lxmf" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(explorer_index_path)
    end
  end
end
