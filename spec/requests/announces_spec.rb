require 'rails_helper'

RSpec.describe "Announces", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get announces_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates an announce and redirects" do
      post announces_path, params: { name: "Test Service", type: "lxmf" }
      expect(response).to have_http_status(:redirect)
    end
  end
end
