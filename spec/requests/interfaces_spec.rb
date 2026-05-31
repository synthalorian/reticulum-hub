require 'rails_helper'

RSpec.describe "Interfaces", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/interfaces/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/interfaces/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/interfaces/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/interfaces/update"
      expect(response).to have_http_status(:success)
    end
  end

end
